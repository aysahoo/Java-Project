package com.assignmentportal.servlet;

import com.assignmentportal.dao.UserDAO;
import com.assignmentportal.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

public class LoginServlet extends HttpServlet {
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to login page
        request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // Validation
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            return;
        }
        
        try {
            // Authenticate user
            User user = userDAO.authenticate(username, password);
            
            if (user != null) {
                // Create session
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("fullName", user.getFullName());
                session.setAttribute("role", user.getRole());
                session.setMaxInactiveInterval(30 * 60); // 30 minutes
                
                // Redirect based on role
                String redirectURL = getRedirectURL(user.getRole());
                response.sendRedirect(request.getContextPath() + redirectURL);
                
            } else {
                request.setAttribute("error", "Invalid username or password");
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        }
    }
    
    private String getRedirectURL(String role) {
        switch (role) {
            case "STUDENT":
                return "/student/dashboard";
            case "TEACHER":
                return "/teacher/dashboard";
            case "ADMIN":
                return "/admin/dashboard";
            default:
                return "/login";
        }
    }
}

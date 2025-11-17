package com.assignmentportal.servlet;

import com.assignmentportal.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class AdminDashboardServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"ADMIN".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        request.getRequestDispatcher("/jsp/admin-dashboard.jsp").forward(request, response);
    }
}

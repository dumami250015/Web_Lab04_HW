<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #333; }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        input[type="text"] {
            width: 50%;
            padding: 10px;
            margin-bottom: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
            font-size: 15px;
        }
        input:focus {
            outline: none;
            border-color: #007bff;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 16px;
        }
        .btn-search {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #28a745;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 16px;
            border: none;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }
        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }
        .pagination {
            margin-top: 20px;
            text-align: center;
        }
        .pagination .btn {
            margin-right: 5px;
            background-color: #6c757d;
        }
        .pagination strong.btn {
            background-color: #007bff;
            color: white;
            cursor: default;
        }
        .pagination a.btn:hover {
            background-color: #5a6268;
        }
        .pagination .btn.disabled {
            background-color: #cac2c2;
            color: #5e6266;
            cursor: not-allowed;
        }
        .table-responsive {
            overflow-x: auto;
        }

        @media (max-width: 768px) {
            table {
                font-size: 12px;
            }
            th, td {
                padding: 5px;
            }
        }

    </style>
    <script>
        setTimeout(function() {
            var messages = document.querySelectorAll('.message');
            messages.forEach(function(msg) {
                msg.style.display = 'none';
            });
        }, 3000);
    </script>
    <script>
        function submitForm(form) {
            var btn = form.querySelector('button[type="submit"]');
            btn.disabled = true;
            btn.textContent = 'Processing...';
            return true;
        }
    </script>
</head>
<body>
<h1>📚 Student Management System</h1>

<% if (request.getParameter("message") != null) { %>
<div class="message success">
    <%= request.getParameter("message") %>
</div>
<% } %>

<% if (request.getParameter("error") != null) { %>
<div class="message error">
    <%= request.getParameter("error") %>
</div>
<% } %>

<%
    String keyword = request.getParameter("keyword");
%>
<form action="list_students.jsp" method="get" onsubmit="return submitForm(this)">
    <% if (keyword != null && !keyword.isEmpty()) { %>
        <input type="text" name="keyword" value=<%= keyword%>>
    <% } else { %>
        <input type="text" name="keyword" placeholder="Search by name or code...">
    <% } %>
    <button type="submit" class="btn-search">Search</button>
    <a href="list_students.jsp" class="btn">Clear</a>
</form>

<a href="add_student.jsp" class="btn">➕ Add New Student</a>

<%
    Connection conn = null;
    Statement stmt = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = "";
    int totalRecords = 0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_management",
                "root",
                "1234"
        );

        if (keyword != null && !keyword.isEmpty()) {
            sql = "SELECT COUNT(*) AS cnt FROM students WHERE full_name LIKE ? OR student_code LIKE ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");
            rs = pstmt.executeQuery();
            if (rs.next()) totalRecords = rs.getInt("cnt");
        } else {
            sql = "SELECT COUNT(*) AS cnt FROM students";
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) totalRecords = rs.getInt("cnt");
        }
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (conn != null) conn.close();
            if (stmt != null) stmt.close();
            if (rs != null) rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    String pageParam = request.getParameter("page");
    int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
    int recordsPerPage = 10;
    int offset = (currentPage - 1) * recordsPerPage;
    int totalPages = (int)Math.ceil((double) totalRecords / recordsPerPage);
%>

<table class="table-responsive">
    <thead>
    <tr>
        <th>ID</th>
        <th>Student Code</th>
        <th>Full Name</th>
        <th>Email</th>
        <th>Major</th>
        <th>Created At</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>

    <%
        conn = null;
        stmt = null;
        pstmt = null;
        rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_management",
                    "root",
                    "1234"
            );

            sql = "";

            if (keyword != null && !keyword.isEmpty()) {
                sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? LIMIT ? OFFSET ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setInt(3, recordsPerPage);
                pstmt.setInt(4, offset);
                rs = pstmt.executeQuery();
            } else {
                sql = "SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, recordsPerPage);
                pstmt.setInt(2, offset);
                rs = pstmt.executeQuery();
            }

            while (rs.next()) {
                int id = rs.getInt("id");
                String studentCode = rs.getString("student_code");
                String fullName = rs.getString("full_name");
                String email = rs.getString("email");
                String major = rs.getString("major");
                Timestamp createdAt = rs.getTimestamp("created_at");
    %>
    <tr>
        <td><%= id %></td>
        <td><%= studentCode %></td>
        <td><%= fullName %></td>
        <td><%= email != null ? email : "N/A" %></td>
        <td><%= major != null ? major : "N/A" %></td>
        <td><%= createdAt %></td>
        <td>
            <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
            <a href="delete_student.jsp?id=<%= id %>"
               class="action-link delete-link"
               onclick="return confirm('Are you sure?')">🗑️ Delete</a>
        </td>
    </tr>
    <%
            }
        } catch (ClassNotFoundException e) {
            out.println("<tr><td colspan='7'>Error: JDBC Driver not found!</td></tr>");
            e.printStackTrace();
        } catch (SQLException e) {
            out.println("<tr><td colspan='7'>Database Error: " + e.getMessage() + "</td></tr>");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
    </tbody>
</table>

<div class="pagination">
    <% if (currentPage > 1) { %>
        <% if (keyword != null && !keyword.isEmpty()) { %>
            <a href="list_students.jsp?page=<%= currentPage - 1 %>&keyword=<%= keyword %>" class="btn">Previous</a>
        <% } else { %>
            <a href="list_students.jsp?page=<%= currentPage - 1 %>" class="btn">Previous</a>
        <% } %>
    <% } else {%>
        <span class="btn disabled">Previous</span>
    <% } %>

    <% for (int i = 1; i <= totalPages; i++) { %>
        <% if (i == currentPage) { %>
            <strong class="btn"><%= i %></strong>
        <% } else { %>
            <% if (keyword != null && !keyword.isEmpty()) { %>
                <a href="list_students.jsp?page=<%= i %>&keyword=<%= keyword %>" class="btn"><%= i %></a>
            <% } else { %>
                <a href="list_students.jsp?page=<%= i %>" class="btn"><%= i %></a>
            <% } %>
        <% } %>
    <% } %>

    <% if (currentPage < totalPages) { %>
        <% if (keyword != null && !keyword.isEmpty()) { %>
            <a href="list_students.jsp?page=<%= currentPage + 1 %>&keyword=<%= keyword %>" class="btn">Next</a>
        <% } else { %>
            <a href="list_students.jsp?page=<%= currentPage + 1 %>" class="btn">Next</a>
        <% } %>
    <% } else { %>
        <span class="btn disabled">Next</span>
    <% } %>
</div>
</body>
</html>

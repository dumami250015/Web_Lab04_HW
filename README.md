# LAB 04 HOMEWORK REPORT

## 1. File Structure & Roles

* `list_students.jsp`: The main page. Displays all students in a paginated table. (Read)
* `add_student.jsp`: A form for adding a new student. (Create - Form)
* `process_add.jsp`: A headless page that processes the form data from `add_student.jsp` and inserts it into the database. (Create - Logic)
* `edit_student.jsp`: A form, pre-filled with data, for editing an existing student. (Update - Form)
* `process_edit.jsp`: A headless page that processes the form data from `edit_student.jsp` and updates the database. (Update - Logic)
* `delete_student.jsp`: A headless page that deletes a student record based on the provided ID. (Delete - Logic)

## 2. Application Code Flow

The application flow is centered around `list_students.jsp`, which acts as the main dashboard. All operations start from this page and return to it with a success or error message.

---

### A. List Students (`list_students.jsp`)

This is the default flow when visiting the application.

1.  **User opens `list_students.jsp`**.
2.  The page immediately runs a Java scriptlet to connect to the MySQL database.
3.  **Pagination Query**: It first runs a `SELECT COUNT(*) FROM students` query to determine the `totalRecords`. This is used to calculate `totalPages` for the pagination controls.
4.  **Data Query**: It then runs a second query, `SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?`, to fetch only the 10 records for the current page (`currentPage`).
5.  **Search**: If a `keyword` parameter is present in the URL, both the `COUNT` and `SELECT` queries are modified with a `WHERE full_name LIKE ? OR student_code LIKE ?` clause.
6.  **Render HTML**: The page loops through the `ResultSet` from the data query and builds the HTML table row by row.
7.  Each row contains links for "Edit" (`edit_student.jsp?id=...`) and "Delete" (`delete_student.jsp?id=...`).

---

### B. Add Student (`add_student.jsp`)

This flow involves three files: `list_students.jsp` -> `add_student.jsp` -> `process_add.jsp`.

1.  User clicks the "➕ Add New Student" button on `list_students.jsp`.
2.  This links to `add_student.jsp`, which displays a blank HTML form.
3.  User fills out the form and clicks "💾 Save Student".
4.  The form `method="POST"` submits the data to `process_add.jsp`.
5.  `process_add.jsp` (a headless page) runs Java code to:
    * Get the form parameters (`student_code`, `full_name`, etc.).
    * Perform server-side validation (check for required fields, validate regex for student code and email).
    * **On Validation Failure**: It redirects the user *back* to `add_student.jsp`, passing the error message in the URL (e.g., `?error=Invalid email format`).
    * **On Validation Success**: It connects to the database, runs an `INSERT INTO students ...` query, and then redirects the user back to `list_students.jsp` with a success message (e.g., `?message=Student added successfully`).

---

### C. Edit Student (`edit_student.jsp`)

This flow is similar to "Create" but involves pre-filling the form.

1.  User clicks the "✏️ Edit" link for a specific student on `list_students.jsp`.
2.  This links to `edit_student.jsp?id=...`, passing the student's ID.
3.  `edit_student.jsp` runs a `SELECT * FROM students WHERE id = ?` query to fetch the data for that single student.
4.  The page displays the HTML form, *pre-filled* with the data from the database.
5.  User modifies the data and clicks "💾 Update".
6.  The form submits to `process_edit.jsp`.
7.  `process_edit.jsp` (headless) validates the new data.
    * **On Failure**: Redirects back to `edit_student.jsp?id=...` with an error.
    * **On Success**: Runs an `UPDATE students SET ... WHERE id = ?` query and redirects to `list_students.jsp` with a success message.

---

### D. Delete Student (`delete_student.jsp`)

This is the simplest flow, involving only two files.

1.  User clicks the "🗑️ Delete" link for a student on `list_students.jsp`.
2.  A JavaScript `confirm('Are you sure?')` dialog appears.
3.  If the user clicks "OK", the browser navigates to `delete_student.jsp?id=...`.
4.  `delete_student.jsp` (headless) immediately connects to the database and runs a `DELETE FROM students WHERE id = ?` query.
5.  After the query, it redirects the user back to `list_students.jsp` with a success or error message.

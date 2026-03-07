-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Mar 07, 2026 at 08:23 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lms`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `admin_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `contact` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`admin_id`, `user_id`, `first_name`, `last_name`, `contact`, `email`) VALUES
(1, 8, 'Muhammad', 'Khuraam', '923047698099', 'saleemkhurram420@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `attendance_id` int(11) NOT NULL,
  `student_course_id` int(11) NOT NULL,
  `course_schedule_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `attendance_status` varchar(20) DEFAULT NULL CHECK (`attendance_status` in ('Present','Absent')),
  `student_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`attendance_id`, `student_course_id`, `course_schedule_id`, `attendance_date`, `attendance_status`, `student_id`) VALUES
(1, 2, 3, '2025-12-31', 'Absent', 3),
(2, 3, 4, '2025-12-31', 'Absent', 4),
(3, 2, 3, '2026-02-04', 'Absent', 3),
(4, 2, 3, '2026-02-04', 'Present', 3),
(5, 3, 4, '2026-02-04', 'Present', 4),
(6, 2, 3, '2026-03-04', 'Absent', 3),
(7, 3, 4, '2026-03-04', 'Present', 4);

-- --------------------------------------------------------

--
-- Table structure for table `complaint_suggestion`
--

CREATE TABLE `complaint_suggestion` (
  `complt_sugst_id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `iamge_name` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `is_status` varchar(50) NOT NULL DEFAULT 'Pending',
  `is_deleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `complaint_suggestion`
--

INSERT INTO `complaint_suggestion` (`complt_sugst_id`, `title`, `description`, `iamge_name`, `user_id`, `is_status`, `is_deleted`) VALUES
(1, 'Result', 'check my result', NULL, 3, 'Solved', 0),
(2, 'Finance_Department', 'Give my salary\r\n', NULL, 4, 'Pending', 0),
(3, 'Exam_Department', 'Where is my shedule??', NULL, 3, 'Pending', 0);

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL,
  `course_name` varchar(100) NOT NULL,
  `course_type` varchar(50) NOT NULL,
  `program_id` int(11) NOT NULL,
  `credit_hours` varchar(50) DEFAULT NULL,
  `no_of_lectures` varchar(50) DEFAULT NULL,
  `assignments_enabled` tinyint(1) DEFAULT 1,
  `quizzes_enabled` tinyint(1) DEFAULT 1,
  `is_deleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`course_id`, `course_name`, `course_type`, `program_id`, `credit_hours`, `no_of_lectures`, `assignments_enabled`, `quizzes_enabled`, `is_deleted`) VALUES
(1, 'Introduction to Computing', 'Regular', 1, '3', '17', 1, 1, 0),
(2, 'Programming Fundamentals', 'Regular', 1, '4', '19', 1, 1, 0),
(3, 'IT Infrastructure', 'Regular', 2, '3', '12', 1, 1, 0),
(4, 'Network Administration', 'Regular', 2, '3', '19', 1, 1, 0),
(5, 'Introduction to AI', 'Regular', 3, '3', '22', 1, 1, 0),
(6, 'Machine Learning', 'Regular', 3, '4', '20', 1, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `course_schedule`
--

CREATE TABLE `course_schedule` (
  `course_schedule_id` int(11) NOT NULL,
  `day_of_week` varchar(10) DEFAULT NULL CHECK (`day_of_week` in ('Monday','Tuesday','Wednesday','Thursday','Friday')),
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `course_id` int(11) NOT NULL,
  `section_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `course_schedule`
--

INSERT INTO `course_schedule` (`course_schedule_id`, `day_of_week`, `start_time`, `end_time`, `location`, `course_id`, `section_id`) VALUES
(1, 'Monday', '09:00:00', '11:00:00', 'Class Room', 1, 1),
(2, 'Monday', '11:00:00', '01:00:00', 'Class Room', 1, 2),
(3, 'Wednesday', '09:00:00', '11:00:00', 'Lab 01', 1, 3),
(4, 'Wednesday', '11:00:00', '02:00:00', 'Lab 02', 1, 4);

-- --------------------------------------------------------

--
-- Table structure for table `fyp_groups`
--

CREATE TABLE `fyp_groups` (
  `fyp_id` int(11) NOT NULL,
  `project_title` text NOT NULL,
  `description` text DEFAULT NULL,
  `teacher_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `status` text DEFAULT 'In Progress',
  `progress` int(11) DEFAULT 0,
  `last_submission` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fyp_groups`
--

INSERT INTO `fyp_groups` (`fyp_id`, `project_title`, `description`, `teacher_id`, `student_id`, `status`, `progress`, `last_submission`, `created_at`) VALUES
(1, 'testing updation of fyp again again2', 'aaaabscs', 1, 2, 'Approved', 0, 'uploads/students_uploads/students_fyp_proposal/SID_2_PROJECT_REPORT-osama-new.pdf', '2026-01-27 06:49:29'),
(2, 'Huzaifa Title pr', 'i am again checking the project ', 1, 3, 'Approved', 0, 'uploads/students_uploads/students_fyp_proposal/SID_3_portfolio-cv.pdf', '2026-01-27 08:44:04'),
(3, 'Developing LMS -Python-Flask-SQL', 'I want to develop the LMS of my University but with python flask and sqlalchemy.', 1, 5, 'Pending Approval', 0, 'uploads/students_uploads/students_fyp_proposal/SID_5_COA_CCP_sol.pdf', '2026-03-05 06:19:33');

-- --------------------------------------------------------

--
-- Table structure for table `fyp_messages`
--

CREATE TABLE `fyp_messages` (
  `message_id` int(11) NOT NULL,
  `fyp_id` int(11) NOT NULL,
  `teacher_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `sender_role` enum('teacher','student') NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fyp_messages`
--

INSERT INTO `fyp_messages` (`message_id`, `fyp_id`, `teacher_id`, `student_id`, `sender_role`, `message`, `created_at`) VALUES
(1, 1, 1, 2, 'teacher', 'hy', '2026-02-24 11:21:54'),
(2, 2, 1, 3, 'teacher', 'hy', '2026-02-24 11:22:04');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_role` enum('student','teacher','admin') NOT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `receiver_role` enum('student','teacher','admin') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `related_course_id` int(11) DEFAULT NULL,
  `status` enum('Pending','Resolved','Rejected') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `programs`
--

CREATE TABLE `programs` (
  `program_id` int(11) NOT NULL,
  `program_name` varchar(100) NOT NULL,
  `program_coordinator` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `programs`
--

INSERT INTO `programs` (`program_id`, `program_name`, `program_coordinator`) VALUES
(1, 'BS Computer Science', 'Zeeshan Haider'),
(2, 'BS Information Technology', 'Ansar Muneer'),
(3, 'BS Artificial Intelligence', 'Shakeeb Ali'),
(4, 'BS Data Science', 'Zohair Haider');

-- --------------------------------------------------------

--
-- Table structure for table `sections`
--

CREATE TABLE `sections` (
  `section_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `section_name` varchar(50) NOT NULL,
  `program_id` int(11) NOT NULL,
  `semester` int(11) NOT NULL,
  `assignments_enabled` tinyint(1) DEFAULT 1,
  `quizzes_enabled` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sections`
--

INSERT INTO `sections` (`section_id`, `course_id`, `section_name`, `program_id`, `semester`, `assignments_enabled`, `quizzes_enabled`) VALUES
(1, 1, 'Blue', 1, 5, 1, 1),
(2, 1, 'Green', 1, 5, 1, 1),
(3, 1, 'Red', 1, 5, 1, 1),
(4, 1, 'Orange', 1, 5, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `semester`
--

CREATE TABLE `semester` (
  `semester_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `year` year(4) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `semester`
--

INSERT INTO `semester` (`semester_id`, `name`, `year`, `start_date`, `end_date`, `created_at`, `is_deleted`) VALUES
(1, 'Fall', '2026', '2026-04-03', '2026-06-03', '2026-03-04 11:09:11', 0),
(2, 'Spring', '2026', '2026-03-04', '2026-04-03', '2026-03-04 11:02:43', 1);

-- --------------------------------------------------------

--
-- Table structure for table `semester_freeze_students`
--

CREATE TABLE `semester_freeze_students` (
  `freeze_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `semester` int(11) NOT NULL,
  `reason` text NOT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `applied_date` datetime DEFAULT current_timestamp(),
  `is_deleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `semester_freeze_students`
--

INSERT INTO `semester_freeze_students` (`freeze_id`, `student_id`, `semester`, `reason`, `status`, `applied_date`, `is_deleted`) VALUES
(1, 3, 5, 'I am checking the semester freeze routes and methods for admin', 'Approved', '2026-03-05 13:36:02', 0);

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `student_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `contact` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `last_qualification` varchar(100) DEFAULT NULL,
  `program_id` int(11) NOT NULL,
  `admission_session` varchar(50) DEFAULT NULL,
  `admission_date` date DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`student_id`, `user_id`, `first_name`, `last_name`, `contact`, `email`, `last_qualification`, `program_id`, `admission_session`, `admission_date`, `is_deleted`) VALUES
(2, 3, 'Umair', 'Ullah', '923150484043', 'ullahcentral123@gmail.com', 'FSC-PreMedical', 1, 'Fall-2023', '2023-10-01', 0),
(3, 5, 'Muhammad', 'Huzaifa', '923047698099', 'huzaifacentral123@gmail.com', 'ICS', 1, 'Fall-2023', '2025-12-31', 0),
(4, 6, 'Muhammad', 'Hammad', '923047698098', 'hammadcentral123@gmail.com', 'FSC-PreMedical', 1, 'Fall-2023', '2025-12-31', 0),
(5, 7, 'Mubeen', 'khurram', '923057698092', 'mubeenmuzaffar123@gmail.com', 'ICS', 3, 'Fall-2026', '2026-03-04', 0),
(6, 9, 'Haris', 'Rizwan', '03047698099', 'hariscentral123@gmail.com', 'Intermediate', 4, 'Spring 2026', '2026-03-04', 1),
(7, 10, 'Aiman', 'Rizwan', '923047698099', 'aiman123@gmail.com', 'FSC-Engrineering', 3, 'Spring 2026', '2026-04-03', 0);

-- --------------------------------------------------------

--
-- Table structure for table `student_course`
--

CREATE TABLE `student_course` (
  `student_course_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_course`
--

INSERT INTO `student_course` (`student_course_id`, `student_id`, `course_id`, `is_deleted`) VALUES
(1, 2, 1, 0),
(2, 3, 1, 0),
(3, 4, 1, 0),
(4, 5, 1, 0),
(5, 7, 3, 0);

-- --------------------------------------------------------

--
-- Table structure for table `student_fail_subjects`
--

CREATE TABLE `student_fail_subjects` (
  `student_fail_id` int(11) NOT NULL,
  `student_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'pending',
  `create_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_fees`
--

CREATE TABLE `student_fees` (
  `student_fees_id` int(11) NOT NULL,
  `fee_amount` decimal(10,2) NOT NULL,
  `fee_status` enum('paid','due') DEFAULT 'due',
  `update_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `voucher_front_pic` varchar(255) DEFAULT NULL,
  `voucher_back_pic` varchar(255) DEFAULT NULL,
  `program_id` int(11) NOT NULL,
  `fee_month` varchar(20) DEFAULT NULL,
  `student_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_fees`
--

INSERT INTO `student_fees` (`student_fees_id`, `fee_amount`, `fee_status`, `update_date`, `voucher_front_pic`, `voucher_back_pic`, `program_id`, `fee_month`, `student_id`) VALUES
(1, 18708.00, 'paid', '2025-12-31 09:10:20', 'uploads/students_uploads/voucher_pics/student_4_front_contact.PNG', 'uploads/students_uploads/voucher_pics/student_4_back_prj.PNG', 1, 'December', 4),
(2, 68102.00, 'paid', '2026-03-05 07:08:03', 'uploads/students_uploads/voucher_pics/student_2_front_dep_view.PNG', 'uploads/students_uploads/voucher_pics/student_2_back_students_view.PNG', 1, 'January', 2),
(3, 18708.00, 'paid', '2026-03-05 07:08:31', NULL, NULL, 4, 'December', 5);

-- --------------------------------------------------------

--
-- Table structure for table `student_improvement`
--

CREATE TABLE `student_improvement` (
  `improvement_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `status` varchar(50) DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_improvement`
--

INSERT INTO `student_improvement` (`improvement_id`, `student_id`, `course_id`, `status`, `created_at`) VALUES
(1, 2, 1, 'Pending', '2026-03-05 07:56:29'),
(2, 3, 4, 'Pending', '2026-03-05 07:57:05');

-- --------------------------------------------------------

--
-- Table structure for table `student_results`
--

CREATE TABLE `student_results` (
  `student_result_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `student_semester` varchar(50) NOT NULL,
  `overall_gpa` decimal(3,2) NOT NULL CHECK (`overall_gpa` between 0.00 and 4.00),
  `result_status` varchar(50) NOT NULL CHECK (`result_status` in ('Pass','Fail'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_results`
--

INSERT INTO `student_results` (`student_result_id`, `student_id`, `student_semester`, `overall_gpa`, `result_status`) VALUES
(2, 2, '5', 1.27, 'Fail'),
(3, 3, '5', 3.70, 'Pass'),
(4, 5, '5', 3.20, 'Pass'),
(5, 4, '5', 3.10, 'Pass');

-- --------------------------------------------------------

--
-- Table structure for table `student_result_marks`
--

CREATE TABLE `student_result_marks` (
  `marks_id` int(11) NOT NULL,
  `student_course_id` int(11) NOT NULL,
  `student_result_id` int(11) NOT NULL,
  `total_marks` int(11) DEFAULT 0,
  `student_grade` varchar(10) NOT NULL,
  `status` varchar(50) NOT NULL,
  `student_semester` varchar(50) DEFAULT NULL,
  `sessional_marks` int(11) DEFAULT 0,
  `mid_marks` int(11) DEFAULT 0,
  `final_marks` int(11) DEFAULT 0,
  `subject_gpa` decimal(3,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_result_marks`
--

INSERT INTO `student_result_marks` (`marks_id`, `student_course_id`, `student_result_id`, `total_marks`, `student_grade`, `status`, `student_semester`, `sessional_marks`, `mid_marks`, `final_marks`, `subject_gpa`) VALUES
(1, 1, 2, 83, 'B+', 'Pass', '5', 17, 23, 43, 0.00),
(2, 1, 2, 83, 'B+', 'Pass', '5', 19, 21, 43, 0.00),
(3, 1, 2, 92, 'A-', 'Pass', '5', 19, 26, 47, 3.80),
(4, 2, 3, 81, 'B+', 'Pass', '5', 14, 23, 44, 3.40),
(5, 2, 3, 95, 'A+', 'Pass', '5', 18, 28, 49, 4.00),
(6, 4, 4, 84, 'B+', 'Pass', '5', 18, 23, 43, 3.40),
(7, 3, 5, 81, 'B+', 'Pass', '5', 13, 23, 45, 3.40);

-- --------------------------------------------------------

--
-- Table structure for table `student_section`
--

CREATE TABLE `student_section` (
  `student_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_section`
--

INSERT INTO `student_section` (`student_id`, `section_id`) VALUES
(2, 1),
(3, 3),
(4, 4),
(5, 2);

-- --------------------------------------------------------

--
-- Table structure for table `student_submissions`
--

CREATE TABLE `student_submissions` (
  `submission_id` int(11) NOT NULL,
  `student_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `section_id` int(11) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `submission_type` enum('assignment','quiz') DEFAULT NULL,
  `upload_date` datetime DEFAULT current_timestamp(),
  `marks` int(11) DEFAULT NULL,
  `total_marks` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_submissions`
--

INSERT INTO `student_submissions` (`submission_id`, `student_id`, `course_id`, `section_id`, `file_path`, `submission_type`, `upload_date`, `marks`, `total_marks`) VALUES
(1, 3, 1, 3, 'uploads/students_uploads/students_assignments/SID3_20260204_120727_new_cover.docx', 'assignment', '2026-02-04 12:07:27', 5, 5),
(2, 3, 1, 3, 'uploads/students_uploads/students_quizes/SID3_20260204_121554_Student_Management_System_Report_Project.docx', 'quiz', '2026-02-04 12:15:54', 2, 5),
(3, 2, 1, 1, 'uploads/students_uploads/students_assignments/SID2_20260204_135331_signup_view.PNG', 'assignment', '2026-02-04 13:53:31', 4, 5),
(4, 4, 1, 4, 'uploads/students_uploads/students_assignments/SID4_20260204_135820_add_view_st.PNG', 'assignment', '2026-02-04 13:58:20', 3, 5),
(5, 4, 1, 4, 'uploads/students_uploads/students_quizes/SID4_20260204_135954_home_view.PNG', 'quiz', '2026-02-04 13:59:54', 3, 5),
(6, 2, 1, 1, 'uploads/students_uploads/students_quizes/SID2_20260204_151638_login_view.PNG', 'quiz', '2026-02-04 15:16:38', 4, 5);

-- --------------------------------------------------------

--
-- Table structure for table `summer_registration`
--

CREATE TABLE `summer_registration` (
  `registration_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `summer_semesters_id` int(11) NOT NULL,
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `summer_registration`
--

INSERT INTO `summer_registration` (`registration_id`, `student_id`, `course_id`, `summer_semesters_id`, `registration_date`) VALUES
(1, 2, 2, 1, '2026-03-05 10:23:25'),
(2, 3, 4, 2, '2026-03-05 11:02:18');

-- --------------------------------------------------------

--
-- Table structure for table `summer_semesters`
--

CREATE TABLE `summer_semesters` (
  `summer_semesters_id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `year` year(4) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `previous_semester_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `summer_semesters`
--

INSERT INTO `summer_semesters` (`summer_semesters_id`, `name`, `year`, `start_date`, `end_date`, `previous_semester_id`, `created_at`, `status`) VALUES
(1, 'Winter', '2026', '2026-03-05', '2026-03-06', 1, '2026-03-05 10:22:54', 'Open'),
(2, 'Summer', '2026', '2026-04-05', '2026-07-05', 1, '2026-03-05 10:25:17', 'Open');

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `setting_key` varchar(50) NOT NULL,
  `setting_value` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`setting_key`, `setting_value`, `description`) VALUES
('current_term', '1', 'Fall 2026'),
('is_admission_open', '0', 'Controls if the signup/admission page is accessible'),
('is_course_reg_open', '1', 'Controls if students can register for new courses'),
('is_summer_app_open', '0', 'Controls if summer semester applications are enabled');

-- --------------------------------------------------------

--
-- Table structure for table `teachers`
--

CREATE TABLE `teachers` (
  `teacher_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `contact_num` varchar(100) NOT NULL,
  `qualification` varchar(100) DEFAULT NULL,
  `joining_date` date DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teachers`
--

INSERT INTO `teachers` (`teacher_id`, `user_id`, `first_name`, `last_name`, `email`, `contact_num`, `qualification`, `joining_date`, `is_deleted`) VALUES
(1, 4, 'sana', 'fatima', 'sanacentral123@gmail.com', '923150484043', 'Graduation', '2025-12-30', 0);

-- --------------------------------------------------------

--
-- Table structure for table `teacher_course`
--

CREATE TABLE `teacher_course` (
  `teacher_course_id` int(11) NOT NULL,
  `teacher_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teacher_course`
--

INSERT INTO `teacher_course` (`teacher_course_id`, `teacher_id`, `course_id`) VALUES
(1, 1, 1),
(2, 1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role_id` int(11) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `email`, `password`, `role_id`, `is_deleted`) VALUES
(1, 'teacher@gmail.com', '12345', 1, 0),
(2, 'student@gmail.com', '54321', 2, 0),
(3, 'ullahcentral123@gmail.com', 'scrypt:32768:8:1$7jPlgi083yfmCTVX$09d66e8cbbcb7df85dba9cc78052ab9d547244815938d89dcbcd01f00d58ff2a7be80bd3a4ad9bc57f84125a3affb624b32a0c0c8a32e85b628f3908fdd59e4c', 1, 0),
(4, 'sanacentral123@gmail.com', 'scrypt:32768:8:1$S7vfbzBO2aRNJpRd$6ffe5515c5085614610d0af9e13e005cfad46755406334ec6804562c60a3511112b3f61fe9f700d8b3a6a315ec1179c8d0377dc0f9bfab76cfd3bc2db693b951', 2, 0),
(5, 'huzaifacentral123@gmail.com', 'scrypt:32768:8:1$I9n0FGjNKaqHRaC4$3e9a48dd81365bda10cf83a4ab1e1eab8c15ac930da13bc1742efef4f4ea57274842f7ab41d824c2c8f135c5f214071ac911d9dd1a334ff553388ab2d0369575', 1, 0),
(6, 'hammadcentral123@gmail.com', 'scrypt:32768:8:1$jfSOWTiPsrWqazKQ$221c31ec18f224255ea2dff9eaf531a035cf704e27918fa7e4364a89d54eeae8af42701c759ba68cd5e7f49c9cf5bb690e8768725f11e63fc7b848f0f2e3de0f', 1, 0),
(7, 'mubeenmuzaffar123@gmail.com', 'scrypt:32768:8:1$ZhqrixLR5MGq8CS2$163df37b57801281972e50959c569da0d91ce77390944d9c2e81729f9a8feab0e9eaa3502ff59bdc825898746268da597de329eeebc9049ff365302bcfb74634', 1, 0),
(8, 'saleemkhurram420@gmail.com', 'scrypt:32768:8:1$skIzf7LpmeXDV7We$46816137a770b3c6ca5f90f7a3c5e03d772807aada70e450473f15803ebf2c5793b04ca86e78101e5da1272c80919b4e8a49d2540aabc7bd51e84d68b91e5e70', 3, 0),
(9, 'hariscentral123@gmail.com', 'scrypt:32768:8:1$R3WyGmnp0WVq4Yr6$3f666a241ec267a81464d1b8ba5efc3937e99b14d0970339055853ed23fb6c024978199950cd6c93e3d97d00d8999db3d286b43a1bf47b30c66cc8f09b55471e', 2, 0),
(10, 'aiman123@gmail.com', 'scrypt:32768:8:1$5K9YM4nseB8f0CJ6$2b429fd8fcb38a2d5611110452b2f1929b785ce2923b3885fd6efa75e0740f70fa0df8f057f47292ae1ea1dcb3d6b5c1cb370e7526ae69a64a1f8e7eab00ddbb', 2, 0);

-- --------------------------------------------------------

--
-- Table structure for table `users_role`
--

CREATE TABLE `users_role` (
  `role_id` int(11) NOT NULL,
  `role_type` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users_role`
--

INSERT INTO `users_role` (`role_id`, `role_type`) VALUES
(3, 'admin'),
(2, 'student'),
(1, 'teacher');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`attendance_id`),
  ADD KEY `student_course_id` (`student_course_id`),
  ADD KEY `course_schedule_id` (`course_schedule_id`),
  ADD KEY `fk_attendance_student` (`student_id`);

--
-- Indexes for table `complaint_suggestion`
--
ALTER TABLE `complaint_suggestion`
  ADD PRIMARY KEY (`complt_sugst_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`course_id`),
  ADD KEY `program_id` (`program_id`);

--
-- Indexes for table `course_schedule`
--
ALTER TABLE `course_schedule`
  ADD PRIMARY KEY (`course_schedule_id`),
  ADD KEY `course_id` (`course_id`),
  ADD KEY `section_id` (`section_id`);

--
-- Indexes for table `fyp_groups`
--
ALTER TABLE `fyp_groups`
  ADD PRIMARY KEY (`fyp_id`),
  ADD KEY `teacher_id` (`teacher_id`),
  ADD KEY `student_id` (`student_id`);

--
-- Indexes for table `fyp_messages`
--
ALTER TABLE `fyp_messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `fyp_id` (`fyp_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `related_course_id` (`related_course_id`),
  ADD KEY `sender_id` (`sender_id`);

--
-- Indexes for table `programs`
--
ALTER TABLE `programs`
  ADD PRIMARY KEY (`program_id`),
  ADD UNIQUE KEY `program_name` (`program_name`);

--
-- Indexes for table `sections`
--
ALTER TABLE `sections`
  ADD PRIMARY KEY (`section_id`),
  ADD KEY `course_id` (`course_id`),
  ADD KEY `program_id` (`program_id`);

--
-- Indexes for table `semester`
--
ALTER TABLE `semester`
  ADD PRIMARY KEY (`semester_id`);

--
-- Indexes for table `semester_freeze_students`
--
ALTER TABLE `semester_freeze_students`
  ADD PRIMARY KEY (`freeze_id`),
  ADD KEY `student_id` (`student_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`student_id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `program_id` (`program_id`);

--
-- Indexes for table `student_course`
--
ALTER TABLE `student_course`
  ADD PRIMARY KEY (`student_course_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `course_id` (`course_id`);

--
-- Indexes for table `student_fail_subjects`
--
ALTER TABLE `student_fail_subjects`
  ADD PRIMARY KEY (`student_fail_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `course_id` (`course_id`);

--
-- Indexes for table `student_fees`
--
ALTER TABLE `student_fees`
  ADD PRIMARY KEY (`student_fees_id`),
  ADD KEY `program_id` (`program_id`),
  ADD KEY `student_id` (`student_id`);

--
-- Indexes for table `student_improvement`
--
ALTER TABLE `student_improvement`
  ADD PRIMARY KEY (`improvement_id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `course_id` (`course_id`);

--
-- Indexes for table `student_results`
--
ALTER TABLE `student_results`
  ADD PRIMARY KEY (`student_result_id`),
  ADD KEY `student_id` (`student_id`);

--
-- Indexes for table `student_result_marks`
--
ALTER TABLE `student_result_marks`
  ADD PRIMARY KEY (`marks_id`),
  ADD KEY `student_course_id` (`student_course_id`),
  ADD KEY `student_result_id` (`student_result_id`);

--
-- Indexes for table `student_section`
--
ALTER TABLE `student_section`
  ADD PRIMARY KEY (`student_id`,`section_id`),
  ADD KEY `section_id` (`section_id`);

--
-- Indexes for table `student_submissions`
--
ALTER TABLE `student_submissions`
  ADD PRIMARY KEY (`submission_id`);

--
-- Indexes for table `summer_registration`
--
ALTER TABLE `summer_registration`
  ADD PRIMARY KEY (`registration_id`),
  ADD KEY `fk_summer_student` (`student_id`),
  ADD KEY `fk_summer_course` (`course_id`),
  ADD KEY `fk_summer_semester` (`summer_semesters_id`);

--
-- Indexes for table `summer_semesters`
--
ALTER TABLE `summer_semesters`
  ADD PRIMARY KEY (`summer_semesters_id`),
  ADD KEY `previous_semester_id` (`previous_semester_id`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`setting_key`);

--
-- Indexes for table `teachers`
--
ALTER TABLE `teachers`
  ADD PRIMARY KEY (`teacher_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `teacher_course`
--
ALTER TABLE `teacher_course`
  ADD PRIMARY KEY (`teacher_course_id`),
  ADD KEY `teacher_id` (`teacher_id`),
  ADD KEY `course_id` (`course_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `role_id` (`role_id`);

--
-- Indexes for table `users_role`
--
ALTER TABLE `users_role`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `role_type` (`role_type`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `attendance_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `complaint_suggestion`
--
ALTER TABLE `complaint_suggestion`
  MODIFY `complt_sugst_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `course_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `course_schedule`
--
ALTER TABLE `course_schedule`
  MODIFY `course_schedule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `fyp_groups`
--
ALTER TABLE `fyp_groups`
  MODIFY `fyp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `fyp_messages`
--
ALTER TABLE `fyp_messages`
  MODIFY `message_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `programs`
--
ALTER TABLE `programs`
  MODIFY `program_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `sections`
--
ALTER TABLE `sections`
  MODIFY `section_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `semester`
--
ALTER TABLE `semester`
  MODIFY `semester_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `semester_freeze_students`
--
ALTER TABLE `semester_freeze_students`
  MODIFY `freeze_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `student_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `student_course`
--
ALTER TABLE `student_course`
  MODIFY `student_course_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `student_fail_subjects`
--
ALTER TABLE `student_fail_subjects`
  MODIFY `student_fail_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_fees`
--
ALTER TABLE `student_fees`
  MODIFY `student_fees_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `student_improvement`
--
ALTER TABLE `student_improvement`
  MODIFY `improvement_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `student_results`
--
ALTER TABLE `student_results`
  MODIFY `student_result_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `student_result_marks`
--
ALTER TABLE `student_result_marks`
  MODIFY `marks_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `student_submissions`
--
ALTER TABLE `student_submissions`
  MODIFY `submission_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `summer_registration`
--
ALTER TABLE `summer_registration`
  MODIFY `registration_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `summer_semesters`
--
ALTER TABLE `summer_semesters`
  MODIFY `summer_semesters_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `teachers`
--
ALTER TABLE `teachers`
  MODIFY `teacher_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `teacher_course`
--
ALTER TABLE `teacher_course`
  MODIFY `teacher_course_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users_role`
--
ALTER TABLE `users_role`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admins`
--
ALTER TABLE `admins`
  ADD CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`student_course_id`) REFERENCES `student_course` (`student_course_id`),
  ADD CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`course_schedule_id`) REFERENCES `course_schedule` (`course_schedule_id`),
  ADD CONSTRAINT `fk_attendance_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

--
-- Constraints for table `complaint_suggestion`
--
ALTER TABLE `complaint_suggestion`
  ADD CONSTRAINT `complaint_suggestion_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`);

--
-- Constraints for table `course_schedule`
--
ALTER TABLE `course_schedule`
  ADD CONSTRAINT `course_schedule_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  ADD CONSTRAINT `course_schedule_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`);

--
-- Constraints for table `fyp_groups`
--
ALTER TABLE `fyp_groups`
  ADD CONSTRAINT `fyp_groups_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`),
  ADD CONSTRAINT `fyp_groups_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

--
-- Constraints for table `fyp_messages`
--
ALTER TABLE `fyp_messages`
  ADD CONSTRAINT `fyp_messages_ibfk_1` FOREIGN KEY (`fyp_id`) REFERENCES `fyp_groups` (`fyp_id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`related_course_id`) REFERENCES `courses` (`course_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `sections`
--
ALTER TABLE `sections`
  ADD CONSTRAINT `sections_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  ADD CONSTRAINT `sections_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`);

--
-- Constraints for table `semester_freeze_students`
--
ALTER TABLE `semester_freeze_students`
  ADD CONSTRAINT `semester_freeze_students_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `students_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`);

--
-- Constraints for table `student_course`
--
ALTER TABLE `student_course`
  ADD CONSTRAINT `student_course_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  ADD CONSTRAINT `student_course_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`);

--
-- Constraints for table `student_fail_subjects`
--
ALTER TABLE `student_fail_subjects`
  ADD CONSTRAINT `student_fail_subjects_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  ADD CONSTRAINT `student_fail_subjects_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`);

--
-- Constraints for table `student_fees`
--
ALTER TABLE `student_fees`
  ADD CONSTRAINT `student_fees_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`),
  ADD CONSTRAINT `student_fees_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

--
-- Constraints for table `student_improvement`
--
ALTER TABLE `student_improvement`
  ADD CONSTRAINT `student_improvement_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  ADD CONSTRAINT `student_improvement_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`);

--
-- Constraints for table `student_results`
--
ALTER TABLE `student_results`
  ADD CONSTRAINT `student_results_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`);

--
-- Constraints for table `student_result_marks`
--
ALTER TABLE `student_result_marks`
  ADD CONSTRAINT `student_result_marks_ibfk_1` FOREIGN KEY (`student_course_id`) REFERENCES `student_course` (`student_course_id`),
  ADD CONSTRAINT `student_result_marks_ibfk_2` FOREIGN KEY (`student_result_id`) REFERENCES `student_results` (`student_result_id`);

--
-- Constraints for table `student_section`
--
ALTER TABLE `student_section`
  ADD CONSTRAINT `student_section_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  ADD CONSTRAINT `student_section_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`);

--
-- Constraints for table `summer_registration`
--
ALTER TABLE `summer_registration`
  ADD CONSTRAINT `fk_summer_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_summer_semester` FOREIGN KEY (`summer_semesters_id`) REFERENCES `summer_semesters` (`summer_semesters_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_summer_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `summer_semesters`
--
ALTER TABLE `summer_semesters`
  ADD CONSTRAINT `summer_semesters_ibfk_1` FOREIGN KEY (`previous_semester_id`) REFERENCES `semester` (`semester_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `teachers`
--
ALTER TABLE `teachers`
  ADD CONSTRAINT `teachers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `teacher_course`
--
ALTER TABLE `teacher_course`
  ADD CONSTRAINT `teacher_course_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`),
  ADD CONSTRAINT `teacher_course_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `users_role` (`role_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

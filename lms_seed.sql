-- ============================================================================
-- LMS COMPLETE SEED SQL FILE
-- Single file with full schema and seeded data
-- 4 Programs | 8 Semesters | 32 Sections (4 per course) | 160 Students (5 per section)
-- ============================================================================

-- Create and use testing database
DROP DATABASE IF EXISTS `testing_db`;
CREATE DATABASE `testing_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `testing_db`;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET FOREIGN_KEY_CHECKS = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- ============================================================================
-- DROP EXISTING TABLES (if any) - in dependency order
-- ============================================================================
DROP TABLE IF EXISTS `summer_registration`;
DROP TABLE IF EXISTS `student_submissions`;
DROP TABLE IF EXISTS `student_result_marks`;
DROP TABLE IF EXISTS `student_results`;
DROP TABLE IF EXISTS `student_improvement`;
DROP TABLE IF EXISTS `student_fail_subjects`;
DROP TABLE IF EXISTS `student_fees`;
DROP TABLE IF EXISTS `semester_freeze_students`;
DROP TABLE IF EXISTS `attendance`;
DROP TABLE IF EXISTS `student_section`;
DROP TABLE IF EXISTS `student_course`;
DROP TABLE IF EXISTS `course_schedule`;
DROP TABLE IF EXISTS `teacher_course`;
DROP TABLE IF EXISTS `fyp_groups`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `complaint_suggestion`;
DROP TABLE IF EXISTS `sections`;
DROP TABLE IF EXISTS `summer_semesters`;
DROP TABLE IF EXISTS `students`;
DROP TABLE IF EXISTS `teachers`;
DROP TABLE IF EXISTS `courses`;
DROP TABLE IF EXISTS `semester`;
DROP TABLE IF EXISTS `programs`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `users_role`;

-- ============================================================================
-- CREATE TABLES
-- ============================================================================

CREATE TABLE `users_role` (
  `role_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `role_type` varchar(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `email` varchar(255) NOT NULL UNIQUE,
  `password` varchar(255) NOT NULL,
  `role_id` int(11) NOT NULL,
  FOREIGN KEY (`role_id`) REFERENCES `users_role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `programs` (
  `program_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `program_name` varchar(100) NOT NULL UNIQUE,
  `program_coordinator` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `semester` (
  `semester_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(50) NOT NULL,
  `year` year(4) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `course_name` varchar(100) NOT NULL,
  `course_type` varchar(50) NOT NULL,
  `program_id` int(11) NOT NULL,
  `credit_hours` varchar(50) DEFAULT NULL,
  `no_of_lectures` varchar(50) DEFAULT NULL,
  `assignments_enabled` tinyint(1) DEFAULT 1,
  `quizzes_enabled` tinyint(1) DEFAULT 1,
  FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `sections` (
  `section_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `course_id` int(11) NOT NULL,
  `section_name` varchar(50) NOT NULL,
  `program_id` int(11) NOT NULL,
  `semester` int(11) NOT NULL,
  `assignments_enabled` tinyint(1) DEFAULT 1,
  `quizzes_enabled` tinyint(1) DEFAULT 1,
  FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `course_schedule` (
  `course_schedule_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `day_of_week` varchar(10) DEFAULT NULL CHECK (`day_of_week` in ('Monday','Tuesday','Wednesday','Thursday','Friday')),
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `course_id` int(11) NOT NULL,
  `section_id` int(11) DEFAULT NULL,
  FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `teachers` (
  `teacher_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` int(11) NOT NULL UNIQUE,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `contact_num` varchar(100) NOT NULL,
  `qualification` varchar(100) DEFAULT NULL,
  `joining_date` date DEFAULT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `teacher_course` (
  `teacher_course_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `teacher_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`),
  FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `students` (
  `student_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` int(11) NOT NULL UNIQUE,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `contact` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `last_qualification` varchar(100) DEFAULT NULL,
  `program_id` int(11) NOT NULL,
  `admission_session` varchar(50) DEFAULT NULL,
  `admission_date` date DEFAULT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `student_section` (
  `student_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  PRIMARY KEY (`student_id`, `section_id`),
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `student_course` (
  `student_course_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `attendance` (
  `attendance_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_course_id` int(11) NOT NULL,
  `course_schedule_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `attendance_status` varchar(20) DEFAULT NULL CHECK (`attendance_status` in ('Present','Absent')),
  `student_id` int(11) DEFAULT NULL,
  FOREIGN KEY (`student_course_id`) REFERENCES `student_course` (`student_course_id`),
  FOREIGN KEY (`course_schedule_id`) REFERENCES `course_schedule` (`course_schedule_id`),
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `student_results` (
  `student_result_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_id` int(11) NOT NULL,
  `student_semester` varchar(50) NOT NULL,
  `overall_gpa` decimal(3,2) NOT NULL CHECK (`overall_gpa` between 0.00 and 4.00),
  `result_status` varchar(50) NOT NULL CHECK (`result_status` in ('Pass','Fail')),
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `student_result_marks` (
  `marks_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_course_id` int(11) NOT NULL,
  `student_result_id` int(11) NOT NULL,
  `total_marks` int(11) DEFAULT 0,
  `student_grade` varchar(10) NOT NULL,
  `status` varchar(50) NOT NULL,
  `student_semester` varchar(50) DEFAULT NULL,
  `sessional_marks` int(11) DEFAULT 0,
  `mid_marks` int(11) DEFAULT 0,
  `final_marks` int(11) DEFAULT 0,
  `subject_gpa` decimal(3,2) DEFAULT 0.00,
  FOREIGN KEY (`student_course_id`) REFERENCES `student_course` (`student_course_id`),
  FOREIGN KEY (`student_result_id`) REFERENCES `student_results` (`student_result_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `student_submissions` (
  `submission_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `section_id` int(11) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `submission_type` enum('assignment','quiz') DEFAULT NULL,
  `upload_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `marks` int(11) DEFAULT NULL,
  `total_marks` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `student_fail_subjects` (
  `student_fail_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'pending',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `student_fees` (
  `student_fees_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `fee_amount` decimal(10,2) NOT NULL,
  `fee_status` enum('paid','due') DEFAULT 'due',
  `update_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `voucher_front_pic` varchar(255) DEFAULT NULL,
  `voucher_back_pic` varchar(255) DEFAULT NULL,
  `program_id` int(11) NOT NULL,
  `fee_month` varchar(20) DEFAULT NULL,
  `student_id` int(11) NOT NULL,
  FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`),
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `student_improvement` (
  `improvement_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `status` varchar(50) DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `semester_freeze_students` (
  `freeze_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_id` int(11) NOT NULL,
  `semester` int(11) NOT NULL,
  `reason` text NOT NULL,
  `status` enum('Pending') DEFAULT 'Pending',
  `applied_date` datetime DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `fyp_groups` (
  `fyp_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `project_title` text NOT NULL,
  `description` text DEFAULT NULL,
  `teacher_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `status` text DEFAULT 'In Progress',
  `progress` int(11) DEFAULT 0,
  `last_submission` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`),
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `complaint_suggestion` (
  `complt_sugst_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `iamge_name` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `sender_id` int(11) NOT NULL,
  `sender_role` enum('student','teacher','admin') NOT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `receiver_role` enum('student','teacher','admin') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `related_course_id` int(11) DEFAULT NULL,
  `status` enum('Pending','Resolved','Rejected') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`related_course_id`) REFERENCES `courses` (`course_id`) ON DELETE SET NULL,
  FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `summer_semesters` (
  `summer_semesters_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(50) DEFAULT NULL,
  `year` year(4) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `previous_semester_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(100) NOT NULL,
  FOREIGN KEY (`previous_semester_id`) REFERENCES `semester` (`semester_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `summer_registration` (
  `registration_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `summer_semesters_id` int(11) NOT NULL,
  `registration_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`summer_semesters_id`) REFERENCES `summer_semesters` (`summer_semesters_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ============================================================================
-- INSERT DATA
-- ============================================================================

-- Roles
INSERT INTO `users_role` (`role_id`, `role_type`) VALUES (1, 'teacher'), (2, 'student');

-- Programs
INSERT INTO `programs` (`program_id`, `program_name`, `program_coordinator`) VALUES
(1, 'BS Computer Science', 'Zeeshan Haider'),
(2, 'BS Information Technology', 'Ansar Muneer'),
(3, 'BS Artificial Intelligence', 'Shakeeb Ali'),
(4, 'BS Data Science', 'Zohair Haider');

-- Semesters (8 semesters)
INSERT INTO `semester` (`semester_id`, `name`, `year`, `start_date`, `end_date`) VALUES
(1, 'Semester 1', 2024, '2024-09-01', '2024-12-15'),
(2, 'Semester 2', 2024, '2025-01-15', '2025-05-15'),
(3, 'Semester 3', 2025, '2025-06-01', '2025-09-15'),
(4, 'Semester 4', 2025, '2025-10-01', '2025-12-15'),
(5, 'Semester 5', 2025, '2026-01-15', '2026-05-15'),
(6, 'Semester 6', 2026, '2026-06-01', '2026-09-15'),
(7, 'Semester 7', 2026, '2026-10-01', '2026-12-15'),
(8, 'Semester 8', 2027, '2027-01-15', '2027-05-15');

-- Courses
INSERT INTO `courses` (`course_id`, `course_name`, `course_type`, `program_id`, `credit_hours`, `no_of_lectures`, `assignments_enabled`, `quizzes_enabled`) VALUES
(1, 'Introduction to Computing', 'Regular', 1, '3', '17', 1, 1),
(2, 'Programming Fundamentals', 'Regular', 1, '4', '19', 1, 1),
(3, 'IT Infrastructure', 'Regular', 2, '3', '12', 1, 1),
(4, 'Network Administration', 'Regular', 2, '3', '19', 1, 1),
(5, 'Introduction to AI', 'Regular', 3, '3', '22', 1, 1),
(6, 'Machine Learning', 'Regular', 3, '4', '20', 1, 1);

-- Sections: 32 total (4 sections per course for each of 8 semesters = 8 sections per course)
-- But we have 6 courses, so let's create 32 sections across 8 semesters
-- Semester 1: Sections 1-4
INSERT INTO `sections` (`section_id`, `course_id`, `section_name`, `program_id`, `semester`, `assignments_enabled`, `quizzes_enabled`) VALUES
(1, 1, 'Red', 1, 1, 1, 1),
(2, 1, 'Blue', 1, 1, 1, 1),
(3, 1, 'Green', 1, 1, 1, 1),
(4, 1, 'Yellow', 1, 1, 1, 1),
-- Semester 2: Sections 5-8
(5, 2, 'Red', 1, 2, 1, 1),
(6, 2, 'Blue', 1, 2, 1, 1),
(7, 2, 'Green', 1, 2, 1, 1),
(8, 2, 'Yellow', 1, 2, 1, 1),
-- Semester 3: Sections 9-12
(9, 3, 'Red', 2, 3, 1, 1),
(10, 3, 'Blue', 2, 3, 1, 1),
(11, 3, 'Green', 2, 3, 1, 1),
(12, 3, 'Yellow', 2, 3, 1, 1),
-- Semester 4: Sections 13-16
(13, 4, 'Red', 2, 4, 1, 1),
(14, 4, 'Blue', 2, 4, 1, 1),
(15, 4, 'Green', 2, 4, 1, 1),
(16, 4, 'Yellow', 2, 4, 1, 1),
-- Semester 5: Sections 17-20
(17, 5, 'Red', 3, 5, 1, 1),
(18, 5, 'Blue', 3, 5, 1, 1),
(19, 5, 'Green', 3, 5, 1, 1),
(20, 5, 'Yellow', 3, 5, 1, 1),
-- Semester 6: Sections 21-24
(21, 6, 'Red', 3, 6, 1, 1),
(22, 6, 'Blue', 3, 6, 1, 1),
(23, 6, 'Green', 3, 6, 1, 1),
(24, 6, 'Yellow', 3, 6, 1, 1),
-- Semester 7: Sections 25-28
(25, 1, 'Red', 1, 7, 1, 1),
(26, 1, 'Blue', 1, 7, 1, 1),
(27, 1, 'Green', 1, 7, 1, 1),
(28, 1, 'Yellow', 1, 7, 1, 1),
-- Semester 8: Sections 29-32
(29, 2, 'Red', 1, 8, 1, 1),
(30, 2, 'Blue', 1, 8, 1, 1),
(31, 2, 'Green', 1, 8, 1, 1),
(32, 2, 'Yellow', 1, 8, 1, 1);

-- Teachers
INSERT INTO `users` (`user_id`, `email`, `password`, `role_id`) VALUES
(1, 'teacher1@gmail.com', 'password123', 1),
(2, 'teacher2@gmail.com', 'password123', 1),
(3, 'teacher3@gmail.com', 'password123', 1),
(4, 'teacher4@gmail.com', 'password123', 1),
(5, 'teacher5@gmail.com', 'password123', 1),
(6, 'teacher6@gmail.com', 'password123', 1);

INSERT INTO `teachers` (`teacher_id`, `user_id`, `first_name`, `last_name`, `email`, `contact_num`, `qualification`, `joining_date`) VALUES
(1, 1, 'Ahmed', 'Khan', 'teacher1@gmail.com', '923150484001', 'M.CS', '2024-01-15'),
(2, 2, 'Fatima', 'Ahmed', 'teacher2@gmail.com', '923150484002', 'M.IT', '2024-02-01'),
(3, 3, 'Ali', 'Hassan', 'teacher3@gmail.com', '923150484003', 'M.AI', '2024-03-01'),
(4, 4, 'Zainab', 'Ali', 'teacher4@gmail.com', '923150484004', 'M.DS', '2024-04-01'),
(5, 5, 'Hassan', 'Malik', 'teacher5@gmail.com', '923150484005', 'M.CS', '2024-05-01'),
(6, 6, 'Sara', 'Khan', 'teacher6@gmail.com', '923150484006', 'M.IT', '2024-06-01');

INSERT INTO `teacher_course` (`teacher_course_id`, `teacher_id`, `course_id`) VALUES
(1, 1, 1), (2, 1, 2), (3, 2, 3), (4, 2, 4), (5, 3, 5), (6, 3, 6);

-- Students: 160 total (5 per section × 32 sections)
-- User IDs: 7-166, Student IDs: 1-160

-- Semester 1 (Sections 1-4): Students 1-20
INSERT INTO `users` (`user_id`, `email`, `password`, `role_id`) VALUES
(7, 'student1@gmail.com', 'password123', 2),
(8, 'student2@gmail.com', 'password123', 2),
(9, 'student3@gmail.com', 'password123', 2),
(10, 'student4@gmail.com', 'password123', 2),
(11, 'student5@gmail.com', 'password123', 2),
(12, 'student6@gmail.com', 'password123', 2),
(13, 'student7@gmail.com', 'password123', 2),
(14, 'student8@gmail.com', 'password123', 2),
(15, 'student9@gmail.com', 'password123', 2),
(16, 'student10@gmail.com', 'password123', 2),
(17, 'student11@gmail.com', 'password123', 2),
(18, 'student12@gmail.com', 'password123', 2),
(19, 'student13@gmail.com', 'password123', 2),
(20, 'student14@gmail.com', 'password123', 2),
(21, 'student15@gmail.com', 'password123', 2),
(22, 'student16@gmail.com', 'password123', 2),
(23, 'student17@gmail.com', 'password123', 2),
(24, 'student18@gmail.com', 'password123', 2),
(25, 'student19@gmail.com', 'password123', 2),
(26, 'student20@gmail.com', 'password123', 2),
-- Semester 2 (Sections 5-8): Students 21-40
(27, 'student21@gmail.com', 'password123', 2),
(28, 'student22@gmail.com', 'password123', 2),
(29, 'student23@gmail.com', 'password123', 2),
(30, 'student24@gmail.com', 'password123', 2),
(31, 'student25@gmail.com', 'password123', 2),
(32, 'student26@gmail.com', 'password123', 2),
(33, 'student27@gmail.com', 'password123', 2),
(34, 'student28@gmail.com', 'password123', 2),
(35, 'student29@gmail.com', 'password123', 2),
(36, 'student30@gmail.com', 'password123', 2),
(37, 'student31@gmail.com', 'password123', 2),
(38, 'student32@gmail.com', 'password123', 2),
(39, 'student33@gmail.com', 'password123', 2),
(40, 'student34@gmail.com', 'password123', 2),
(41, 'student35@gmail.com', 'password123', 2),
(42, 'student36@gmail.com', 'password123', 2),
(43, 'student37@gmail.com', 'password123', 2),
(44, 'student38@gmail.com', 'password123', 2),
(45, 'student39@gmail.com', 'password123', 2),
(46, 'student40@gmail.com', 'password123', 2),
-- Semester 3 (Sections 9-12): Students 41-60
(47, 'student41@gmail.com', 'password123', 2),
(48, 'student42@gmail.com', 'password123', 2),
(49, 'student43@gmail.com', 'password123', 2),
(50, 'student44@gmail.com', 'password123', 2),
(51, 'student45@gmail.com', 'password123', 2),
(52, 'student46@gmail.com', 'password123', 2),
(53, 'student47@gmail.com', 'password123', 2),
(54, 'student48@gmail.com', 'password123', 2),
(55, 'student49@gmail.com', 'password123', 2),
(56, 'student50@gmail.com', 'password123', 2),
(57, 'student51@gmail.com', 'password123', 2),
(58, 'student52@gmail.com', 'password123', 2),
(59, 'student53@gmail.com', 'password123', 2),
(60, 'student54@gmail.com', 'password123', 2),
(61, 'student55@gmail.com', 'password123', 2),
(62, 'student56@gmail.com', 'password123', 2),
(63, 'student57@gmail.com', 'password123', 2),
(64, 'student58@gmail.com', 'password123', 2),
(65, 'student59@gmail.com', 'password123', 2),
(66, 'student60@gmail.com', 'password123', 2),
-- Semester 4 (Sections 13-16): Students 61-80
(67, 'student61@gmail.com', 'password123', 2),
(68, 'student62@gmail.com', 'password123', 2),
(69, 'student63@gmail.com', 'password123', 2),
(70, 'student64@gmail.com', 'password123', 2),
(71, 'student65@gmail.com', 'password123', 2),
(72, 'student66@gmail.com', 'password123', 2),
(73, 'student67@gmail.com', 'password123', 2),
(74, 'student68@gmail.com', 'password123', 2),
(75, 'student69@gmail.com', 'password123', 2),
(76, 'student70@gmail.com', 'password123', 2),
(77, 'student71@gmail.com', 'password123', 2),
(78, 'student72@gmail.com', 'password123', 2),
(79, 'student73@gmail.com', 'password123', 2),
(80, 'student74@gmail.com', 'password123', 2),
(81, 'student75@gmail.com', 'password123', 2),
(82, 'student76@gmail.com', 'password123', 2),
(83, 'student77@gmail.com', 'password123', 2),
(84, 'student78@gmail.com', 'password123', 2),
(85, 'student79@gmail.com', 'password123', 2),
(86, 'student80@gmail.com', 'password123', 2),
-- Semester 5 (Sections 17-20): Students 81-100
(87, 'student81@gmail.com', 'password123', 2),
(88, 'student82@gmail.com', 'password123', 2),
(89, 'student83@gmail.com', 'password123', 2),
(90, 'student84@gmail.com', 'password123', 2),
(91, 'student85@gmail.com', 'password123', 2),
(92, 'student86@gmail.com', 'password123', 2),
(93, 'student87@gmail.com', 'password123', 2),
(94, 'student88@gmail.com', 'password123', 2),
(95, 'student89@gmail.com', 'password123', 2),
(96, 'student90@gmail.com', 'password123', 2),
(97, 'student91@gmail.com', 'password123', 2),
(98, 'student92@gmail.com', 'password123', 2),
(99, 'student93@gmail.com', 'password123', 2),
(100, 'student94@gmail.com', 'password123', 2),
(101, 'student95@gmail.com', 'password123', 2),
(102, 'student96@gmail.com', 'password123', 2),
(103, 'student97@gmail.com', 'password123', 2),
(104, 'student98@gmail.com', 'password123', 2),
(105, 'student99@gmail.com', 'password123', 2),
(106, 'student100@gmail.com', 'password123', 2),
-- Semester 6 (Sections 21-24): Students 101-120
(107, 'student101@gmail.com', 'password123', 2),
(108, 'student102@gmail.com', 'password123', 2),
(109, 'student103@gmail.com', 'password123', 2),
(110, 'student104@gmail.com', 'password123', 2),
(111, 'student105@gmail.com', 'password123', 2),
(112, 'student106@gmail.com', 'password123', 2),
(113, 'student107@gmail.com', 'password123', 2),
(114, 'student108@gmail.com', 'password123', 2),
(115, 'student109@gmail.com', 'password123', 2),
(116, 'student110@gmail.com', 'password123', 2),
(117, 'student111@gmail.com', 'password123', 2),
(118, 'student112@gmail.com', 'password123', 2),
(119, 'student113@gmail.com', 'password123', 2),
(120, 'student114@gmail.com', 'password123', 2),
(121, 'student115@gmail.com', 'password123', 2),
(122, 'student116@gmail.com', 'password123', 2),
(123, 'student117@gmail.com', 'password123', 2),
(124, 'student118@gmail.com', 'password123', 2),
(125, 'student119@gmail.com', 'password123', 2),
(126, 'student120@gmail.com', 'password123', 2),
-- Semester 7 (Sections 25-28): Students 121-140
(127, 'student121@gmail.com', 'password123', 2),
(128, 'student122@gmail.com', 'password123', 2),
(129, 'student123@gmail.com', 'password123', 2),
(130, 'student124@gmail.com', 'password123', 2),
(131, 'student125@gmail.com', 'password123', 2),
(132, 'student126@gmail.com', 'password123', 2),
(133, 'student127@gmail.com', 'password123', 2),
(134, 'student128@gmail.com', 'password123', 2),
(135, 'student129@gmail.com', 'password123', 2),
(136, 'student130@gmail.com', 'password123', 2),
(137, 'student131@gmail.com', 'password123', 2),
(138, 'student132@gmail.com', 'password123', 2),
(139, 'student133@gmail.com', 'password123', 2),
(140, 'student134@gmail.com', 'password123', 2),
(141, 'student135@gmail.com', 'password123', 2),
(142, 'student136@gmail.com', 'password123', 2),
(143, 'student137@gmail.com', 'password123', 2),
(144, 'student138@gmail.com', 'password123', 2),
(145, 'student139@gmail.com', 'password123', 2),
(146, 'student140@gmail.com', 'password123', 2),
-- Semester 8 (Sections 29-32): Students 141-160
(147, 'student141@gmail.com', 'password123', 2),
(148, 'student142@gmail.com', 'password123', 2),
(149, 'student143@gmail.com', 'password123', 2),
(150, 'student144@gmail.com', 'password123', 2),
(151, 'student145@gmail.com', 'password123', 2),
(152, 'student146@gmail.com', 'password123', 2),
(153, 'student147@gmail.com', 'password123', 2),
(154, 'student148@gmail.com', 'password123', 2),
(155, 'student149@gmail.com', 'password123', 2),
(156, 'student150@gmail.com', 'password123', 2),
(157, 'student151@gmail.com', 'password123', 2),
(158, 'student152@gmail.com', 'password123', 2),
(159, 'student153@gmail.com', 'password123', 2),
(160, 'student154@gmail.com', 'password123', 2),
(161, 'student155@gmail.com', 'password123', 2),
(162, 'student156@gmail.com', 'password123', 2),
(163, 'student157@gmail.com', 'password123', 2),
(164, 'student158@gmail.com', 'password123', 2),
(165, 'student159@gmail.com', 'password123', 2),
(166, 'student160@gmail.com', 'password123', 2);

-- Insert Students (160 total)
INSERT INTO `students` (`student_id`, `user_id`, `first_name`, `last_name`, `contact`, `email`, `last_qualification`, `program_id`, `admission_session`, `admission_date`) VALUES
-- Semester 1 Students (1-20)
(1, 7, 'Muhammad', 'Ali', '923150484010', 'student1@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(2, 8, 'Ayesha', 'Khan', '923150484011', 'student2@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(3, 9, 'Hassan', 'Ahmed', '923150484012', 'student3@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(4, 10, 'Zainab', 'Ali', '923150484013', 'student4@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(5, 11, 'Omar', 'Hassan', '923150484014', 'student5@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(6, 12, 'Fatima', 'Malik', '923150484015', 'student6@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(7, 13, 'Ali', 'Raza', '923150484016', 'student7@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(8, 14, 'Sara', 'Khan', '923150484017', 'student8@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(9, 15, 'Ahmed', 'Malik', '923150484018', 'student9@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(10, 16, 'Hiba', 'Hassan', '923150484019', 'student10@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(11, 17, 'Usman', 'Khan', '923150484020', 'student11@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(12, 18, 'Hina', 'Ahmed', '923150484021', 'student12@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(13, 19, 'Karim', 'Ali', '923150484022', 'student13@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(14, 20, 'Noor', 'Hassan', '923150484023', 'student14@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(15, 21, 'Bilal', 'Khan', '923150484024', 'student15@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(16, 22, 'Mariam', 'Malik', '923150484025', 'student16@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(17, 23, 'Faisal', 'Raza', '923150484026', 'student17@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(18, 24, 'Amina', 'Khan', '923150484027', 'student18@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(19, 25, 'Ibrahim', 'Hassan', '923150484028', 'student19@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(20, 26, 'Layla', 'Ahmed', '923150484029', 'student20@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
-- Semester 2 Students (21-40)
(21, 27, 'Tariq', 'Khan', '923150484030', 'student21@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(22, 28, 'Nadia', 'Ahmed', '923150484031', 'student22@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(23, 29, 'Rashid', 'Malik', '923150484032', 'student23@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(24, 30, 'Leila', 'Hassan', '923150484033', 'student24@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(25, 31, 'Mustafa', 'Khan', '923150484034', 'student25@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(26, 32, 'Samira', 'Malik', '923150484035', 'student26@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(27, 33, 'Khalid', 'Raza', '923150484036', 'student27@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(28, 34, 'Rania', 'Khan', '923150484037', 'student28@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(29, 35, 'Jamal', 'Malik', '923150484038', 'student29@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(30, 36, 'Yasmin', 'Hassan', '923150484039', 'student30@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(31, 37, 'Samir', 'Khan', '923150484040', 'student31@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(32, 38, 'Dina', 'Ahmed', '923150484041', 'student32@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(33, 39, 'Youssef', 'Ali', '923150484042', 'student33@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(34, 40, 'Leila', 'Hassan', '923150484043', 'student34@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(35, 41, 'Adnan', 'Khan', '923150484044', 'student35@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(36, 42, 'Mona', 'Malik', '923150484045', 'student36@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(37, 43, 'Saad', 'Raza', '923150484046', 'student37@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(38, 44, 'Hana', 'Khan', '923150484047', 'student38@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(39, 45, 'Rafiq', 'Malik', '923150484048', 'student39@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(40, 46, 'Lamar', 'Hassan', '923150484049', 'student40@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
-- Semester 3 Students (41-60)
(41, 47, 'Karim', 'Khan', '923150484050', 'student41@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(42, 48, 'Nadia', 'Ahmed', '923150484051', 'student42@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(43, 49, 'Rashid', 'Malik', '923150484052', 'student43@gmail.com', 'ICS', 2, 'Fall-2024', '2024-09-01'),
(44, 50, 'Leila', 'Hassan', '923150484053', 'student44@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(45, 51, 'Mustafa', 'Khan', '923150484054', 'student45@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(46, 52, 'Samira', 'Malik', '923150484055', 'student46@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(47, 53, 'Khalid', 'Raza', '923150484056', 'student47@gmail.com', 'ICS', 2, 'Fall-2024', '2024-09-01'),
(48, 54, 'Rania', 'Khan', '923150484057', 'student48@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(49, 55, 'Jamal', 'Malik', '923150484058', 'student49@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(50, 56, 'Yasmin', 'Hassan', '923150484059', 'student50@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(51, 57, 'Samir', 'Khan', '923150484060', 'student51@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(52, 58, 'Dina', 'Ahmed', '923150484061', 'student52@gmail.com', 'ICS', 2, 'Fall-2024', '2024-09-01'),
(53, 59, 'Youssef', 'Ali', '923150484062', 'student53@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(54, 60, 'Leila', 'Hassan', '923150484063', 'student54@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(55, 61, 'Adnan', 'Khan', '923150484064', 'student55@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(56, 62, 'Mona', 'Malik', '923150484065', 'student56@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(57, 63, 'Saad', 'Raza', '923150484066', 'student57@gmail.com', 'ICS', 2, 'Fall-2024', '2024-09-01'),
(58, 64, 'Hana', 'Khan', '923150484067', 'student58@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(59, 65, 'Rafiq', 'Malik', '923150484068', 'student59@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(60, 66, 'Lamar', 'Hassan', '923150484069', 'student60@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
-- Semester 4 Students (61-80)
(61, 67, 'Karim', 'Khan', '923150484070', 'student61@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(62, 68, 'Nadia', 'Ahmed', '923150484071', 'student62@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(63, 69, 'Rashid', 'Malik', '923150484072', 'student63@gmail.com', 'ICS', 2, 'Fall-2024', '2024-09-01'),
(64, 70, 'Leila', 'Hassan', '923150484073', 'student64@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(65, 71, 'Mustafa', 'Khan', '923150484074', 'student65@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(66, 72, 'Samira', 'Malik', '923150484075', 'student66@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(67, 73, 'Khalid', 'Raza', '923150484076', 'student67@gmail.com', 'ICS', 2, 'Fall-2024', '2024-09-01'),
(68, 74, 'Rania', 'Khan', '923150484077', 'student68@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(69, 75, 'Jamal', 'Malik', '923150484078', 'student69@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(70, 76, 'Yasmin', 'Hassan', '923150484079', 'student70@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(71, 77, 'Samir', 'Khan', '923150484080', 'student71@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(72, 78, 'Dina', 'Ahmed', '923150484081', 'student72@gmail.com', 'ICS', 2, 'Fall-2024', '2024-09-01'),
(73, 79, 'Youssef', 'Ali', '923150484082', 'student73@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(74, 80, 'Leila', 'Hassan', '923150484083', 'student74@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(75, 81, 'Adnan', 'Khan', '923150484084', 'student75@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(76, 82, 'Mona', 'Malik', '923150484085', 'student76@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(77, 83, 'Saad', 'Raza', '923150484086', 'student77@gmail.com', 'ICS', 2, 'Fall-2024', '2024-09-01'),
(78, 84, 'Hana', 'Khan', '923150484087', 'student78@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(79, 85, 'Rafiq', 'Malik', '923150484088', 'student79@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
(80, 86, 'Lamar', 'Hassan', '923150484089', 'student80@gmail.com', 'FSC-PreMedical', 2, 'Fall-2024', '2024-09-01'),
-- Semester 5 Students (81-100)
(81, 87, 'Karim', 'Khan', '923150484090', 'student81@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(82, 88, 'Nadia', 'Ahmed', '923150484091', 'student82@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(83, 89, 'Rashid', 'Malik', '923150484092', 'student83@gmail.com', 'ICS', 3, 'Fall-2024', '2024-09-01'),
(84, 90, 'Leila', 'Hassan', '923150484093', 'student84@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(85, 91, 'Mustafa', 'Khan', '923150484094', 'student85@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(86, 92, 'Samira', 'Malik', '923150484095', 'student86@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(87, 93, 'Khalid', 'Raza', '923150484096', 'student87@gmail.com', 'ICS', 3, 'Fall-2024', '2024-09-01'),
(88, 94, 'Rania', 'Khan', '923150484097', 'student88@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(89, 95, 'Jamal', 'Malik', '923150484098', 'student89@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(90, 96, 'Yasmin', 'Hassan', '923150484099', 'student90@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(91, 97, 'Samir', 'Khan', '923150484100', 'student91@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(92, 98, 'Dina', 'Ahmed', '923150484101', 'student92@gmail.com', 'ICS', 3, 'Fall-2024', '2024-09-01'),
(93, 99, 'Youssef', 'Ali', '923150484102', 'student93@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(94, 100, 'Leila', 'Hassan', '923150484103', 'student94@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(95, 101, 'Adnan', 'Khan', '923150484104', 'student95@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(96, 102, 'Mona', 'Malik', '923150484105', 'student96@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(97, 103, 'Saad', 'Raza', '923150484106', 'student97@gmail.com', 'ICS', 3, 'Fall-2024', '2024-09-01'),
(98, 104, 'Hana', 'Khan', '923150484107', 'student98@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(99, 105, 'Rafiq', 'Malik', '923150484108', 'student99@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(100, 106, 'Lamar', 'Hassan', '923150484109', 'student100@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
-- Semester 6 Students (101-120)
(101, 107, 'Karim', 'Khan', '923150484110', 'student101@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(102, 108, 'Nadia', 'Ahmed', '923150484111', 'student102@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(103, 109, 'Rashid', 'Malik', '923150484112', 'student103@gmail.com', 'ICS', 3, 'Fall-2024', '2024-09-01'),
(104, 110, 'Leila', 'Hassan', '923150484113', 'student104@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(105, 111, 'Mustafa', 'Khan', '923150484114', 'student105@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(106, 112, 'Samira', 'Malik', '923150484115', 'student106@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(107, 113, 'Khalid', 'Raza', '923150484116', 'student107@gmail.com', 'ICS', 3, 'Fall-2024', '2024-09-01'),
(108, 114, 'Rania', 'Khan', '923150484117', 'student108@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(109, 115, 'Jamal', 'Malik', '923150484118', 'student109@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(110, 116, 'Yasmin', 'Hassan', '923150484119', 'student110@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(111, 117, 'Samir', 'Khan', '923150484120', 'student111@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(112, 118, 'Dina', 'Ahmed', '923150484121', 'student112@gmail.com', 'ICS', 3, 'Fall-2024', '2024-09-01'),
(113, 119, 'Youssef', 'Ali', '923150484122', 'student113@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(114, 120, 'Leila', 'Hassan', '923150484123', 'student114@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(115, 121, 'Adnan', 'Khan', '923150484124', 'student115@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(116, 122, 'Mona', 'Malik', '923150484125', 'student116@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(117, 123, 'Saad', 'Raza', '923150484126', 'student117@gmail.com', 'ICS', 3, 'Fall-2024', '2024-09-01'),
(118, 124, 'Hana', 'Khan', '923150484127', 'student118@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(119, 125, 'Rafiq', 'Malik', '923150484128', 'student119@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
(120, 126, 'Lamar', 'Hassan', '923150484129', 'student120@gmail.com', 'FSC-PreMedical', 3, 'Fall-2024', '2024-09-01'),
-- Semester 7 Students (121-140)
(121, 127, 'Karim', 'Khan', '923150484130', 'student121@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(122, 128, 'Nadia', 'Ahmed', '923150484131', 'student122@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(123, 129, 'Rashid', 'Malik', '923150484132', 'student123@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(124, 130, 'Leila', 'Hassan', '923150484133', 'student124@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(125, 131, 'Mustafa', 'Khan', '923150484134', 'student125@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(126, 132, 'Samira', 'Malik', '923150484135', 'student126@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(127, 133, 'Khalid', 'Raza', '923150484136', 'student127@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(128, 134, 'Rania', 'Khan', '923150484137', 'student128@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(129, 135, 'Jamal', 'Malik', '923150484138', 'student129@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(130, 136, 'Yasmin', 'Hassan', '923150484139', 'student130@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(131, 137, 'Samir', 'Khan', '923150484140', 'student131@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(132, 138, 'Dina', 'Ahmed', '923150484141', 'student132@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(133, 139, 'Youssef', 'Ali', '923150484142', 'student133@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(134, 140, 'Leila', 'Hassan', '923150484143', 'student134@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(135, 141, 'Adnan', 'Khan', '923150484144', 'student135@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(136, 142, 'Mona', 'Malik', '923150484145', 'student136@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(137, 143, 'Saad', 'Raza', '923150484146', 'student137@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(138, 144, 'Hana', 'Khan', '923150484147', 'student138@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(139, 145, 'Rafiq', 'Malik', '923150484148', 'student139@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(140, 146, 'Lamar', 'Hassan', '923150484149', 'student140@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
-- Semester 8 Students (141-160)
(141, 147, 'Karim', 'Khan', '923150484150', 'student141@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(142, 148, 'Nadia', 'Ahmed', '923150484151', 'student142@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(143, 149, 'Rashid', 'Malik', '923150484152', 'student143@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(144, 150, 'Leila', 'Hassan', '923150484153', 'student144@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(145, 151, 'Mustafa', 'Khan', '923150484154', 'student145@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(146, 152, 'Samira', 'Malik', '923150484155', 'student146@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(147, 153, 'Khalid', 'Raza', '923150484156', 'student147@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(148, 154, 'Rania', 'Khan', '923150484157', 'student148@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(149, 155, 'Jamal', 'Malik', '923150484158', 'student149@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(150, 156, 'Yasmin', 'Hassan', '923150484159', 'student150@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(151, 157, 'Samir', 'Khan', '923150484160', 'student151@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(152, 158, 'Dina', 'Ahmed', '923150484161', 'student152@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(153, 159, 'Youssef', 'Ali', '923150484162', 'student153@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(154, 160, 'Leila', 'Hassan', '923150484163', 'student154@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(155, 161, 'Adnan', 'Khan', '923150484164', 'student155@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(156, 162, 'Mona', 'Malik', '923150484165', 'student156@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(157, 163, 'Saad', 'Raza', '923150484166', 'student157@gmail.com', 'ICS', 1, 'Fall-2024', '2024-09-01'),
(158, 164, 'Hana', 'Khan', '923150484167', 'student158@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(159, 165, 'Rafiq', 'Malik', '923150484168', 'student159@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01'),
(160, 166, 'Lamar', 'Hassan', '923150484169', 'student160@gmail.com', 'FSC-PreMedical', 1, 'Fall-2024', '2024-09-01');

-- Insert student-section assignments (5 students per section × 32 sections)
-- Semester 1 - Section 1 (Red): Students 1-5
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (1, 1), (2, 1), (3, 1), (4, 1), (5, 1);
-- Semester 1 - Section 2 (Blue): Students 6-10
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (6, 2), (7, 2), (8, 2), (9, 2), (10, 2);
-- Semester 1 - Section 3 (Green): Students 11-15
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (11, 3), (12, 3), (13, 3), (14, 3), (15, 3);
-- Semester 1 - Section 4 (Yellow): Students 16-20
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (16, 4), (17, 4), (18, 4), (19, 4), (20, 4);
-- Semester 2 - Section 5 (Red): Students 21-25
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (21, 5), (22, 5), (23, 5), (24, 5), (25, 5);
-- Semester 2 - Section 6 (Blue): Students 26-30
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (26, 6), (27, 6), (28, 6), (29, 6), (30, 6);
-- Semester 2 - Section 7 (Green): Students 31-35
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (31, 7), (32, 7), (33, 7), (34, 7), (35, 7);
-- Semester 2 - Section 8 (Yellow): Students 36-40
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (36, 8), (37, 8), (38, 8), (39, 8), (40, 8);
-- Semester 3 - Section 9 (Red): Students 41-45
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (41, 9), (42, 9), (43, 9), (44, 9), (45, 9);
-- Semester 3 - Section 10 (Blue): Students 46-50
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (46, 10), (47, 10), (48, 10), (49, 10), (50, 10);
-- Semester 3 - Section 11 (Green): Students 51-55
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (51, 11), (52, 11), (53, 11), (54, 11), (55, 11);
-- Semester 3 - Section 12 (Yellow): Students 56-60
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (56, 12), (57, 12), (58, 12), (59, 12), (60, 12);
-- Semester 4 - Section 13 (Red): Students 61-65
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (61, 13), (62, 13), (63, 13), (64, 13), (65, 13);
-- Semester 4 - Section 14 (Blue): Students 66-70
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (66, 14), (67, 14), (68, 14), (69, 14), (70, 14);
-- Semester 4 - Section 15 (Green): Students 71-75
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (71, 15), (72, 15), (73, 15), (74, 15), (75, 15);
-- Semester 4 - Section 16 (Yellow): Students 76-80
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (76, 16), (77, 16), (78, 16), (79, 16), (80, 16);
-- Semester 5 - Section 17 (Red): Students 81-85
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (81, 17), (82, 17), (83, 17), (84, 17), (85, 17);
-- Semester 5 - Section 18 (Blue): Students 86-90
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (86, 18), (87, 18), (88, 18), (89, 18), (90, 18);
-- Semester 5 - Section 19 (Green): Students 91-95
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (91, 19), (92, 19), (93, 19), (94, 19), (95, 19);
-- Semester 5 - Section 20 (Yellow): Students 96-100
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (96, 20), (97, 20), (98, 20), (99, 20), (100, 20);
-- Semester 6 - Section 21 (Red): Students 101-105
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (101, 21), (102, 21), (103, 21), (104, 21), (105, 21);
-- Semester 6 - Section 22 (Blue): Students 106-110
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (106, 22), (107, 22), (108, 22), (109, 22), (110, 22);
-- Semester 6 - Section 23 (Green): Students 111-115
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (111, 23), (112, 23), (113, 23), (114, 23), (115, 23);
-- Semester 6 - Section 24 (Yellow): Students 116-120
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (116, 24), (117, 24), (118, 24), (119, 24), (120, 24);
-- Semester 7 - Section 25 (Red): Students 121-125
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (121, 25), (122, 25), (123, 25), (124, 25), (125, 25);
-- Semester 7 - Section 26 (Blue): Students 126-130
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (126, 26), (127, 26), (128, 26), (129, 26), (130, 26);
-- Semester 7 - Section 27 (Green): Students 131-135
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (131, 27), (132, 27), (133, 27), (134, 27), (135, 27);
-- Semester 7 - Section 28 (Yellow): Students 136-140
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (136, 28), (137, 28), (138, 28), (139, 28), (140, 28);
-- Semester 8 - Section 29 (Red): Students 141-145
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (141, 29), (142, 29), (143, 29), (144, 29), (145, 29);
-- Semester 8 - Section 30 (Blue): Students 146-150
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (146, 30), (147, 30), (148, 30), (149, 30), (150, 30);
-- Semester 8 - Section 31 (Green): Students 151-155
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (151, 31), (152, 31), (153, 31), (154, 31), (155, 31);
-- Semester 8 - Section 32 (Yellow): Students 156-160
INSERT INTO `student_section` (`student_id`, `section_id`) VALUES (156, 32), (157, 32), (158, 32), (159, 32), (160, 32);

-- Insert student-course enrollments (each student in 3 courses)
-- Semester 1 students enrolled in courses 1,2,3
INSERT INTO `student_course` (`student_id`, `course_id`) VALUES
(1,1),(1,2),(1,3),(2,1),(2,2),(2,3),(3,1),(3,2),(3,3),(4,1),(4,2),(4,3),(5,1),(5,2),(5,3),
(6,1),(6,2),(6,3),(7,1),(7,2),(7,3),(8,1),(8,2),(8,3),(9,1),(9,2),(9,3),(10,1),(10,2),(10,3),
(11,1),(11,2),(11,3),(12,1),(12,2),(12,3),(13,1),(13,2),(13,3),(14,1),(14,2),(14,3),(15,1),(15,2),(15,3),
(16,1),(16,2),(16,3),(17,1),(17,2),(17,3),(18,1),(18,2),(18,3),(19,1),(19,2),(19,3),(20,1),(20,2),(20,3);

-- Semester 2 students enrolled in courses 2,3,4
INSERT INTO `student_course` (`student_id`, `course_id`) VALUES
(21,2),(21,3),(21,4),(22,2),(22,3),(22,4),(23,2),(23,3),(23,4),(24,2),(24,3),(24,4),(25,2),(25,3),(25,4),
(26,2),(26,3),(26,4),(27,2),(27,3),(27,4),(28,2),(28,3),(28,4),(29,2),(29,3),(29,4),(30,2),(30,3),(30,4),
(31,2),(31,3),(31,4),(32,2),(32,3),(32,4),(33,2),(33,3),(33,4),(34,2),(34,3),(34,4),(35,2),(35,3),(35,4),
(36,2),(36,3),(36,4),(37,2),(37,3),(37,4),(38,2),(38,3),(38,4),(39,2),(39,3),(39,4),(40,2),(40,3),(40,4);

-- Semester 3 students enrolled in courses 3,4,5
INSERT INTO `student_course` (`student_id`, `course_id`) VALUES
(41,3),(41,4),(41,5),(42,3),(42,4),(42,5),(43,3),(43,4),(43,5),(44,3),(44,4),(44,5),(45,3),(45,4),(45,5),
(46,3),(46,4),(46,5),(47,3),(47,4),(47,5),(48,3),(48,4),(48,5),(49,3),(49,4),(49,5),(50,3),(50,4),(50,5),
(51,3),(51,4),(51,5),(52,3),(52,4),(52,5),(53,3),(53,4),(53,5),(54,3),(54,4),(54,5),(55,3),(55,4),(55,5),
(56,3),(56,4),(56,5),(57,3),(57,4),(57,5),(58,3),(58,4),(58,5),(59,3),(59,4),(59,5),(60,3),(60,4),(60,5);

-- Semester 4 students enrolled in courses 4,5,6
INSERT INTO `student_course` (`student_id`, `course_id`) VALUES
(61,4),(61,5),(61,6),(62,4),(62,5),(62,6),(63,4),(63,5),(63,6),(64,4),(64,5),(64,6),(65,4),(65,5),(65,6),
(66,4),(66,5),(66,6),(67,4),(67,5),(67,6),(68,4),(68,5),(68,6),(69,4),(69,5),(69,6),(70,4),(70,5),(70,6),
(71,4),(71,5),(71,6),(72,4),(72,5),(72,6),(73,4),(73,5),(73,6),(74,4),(74,5),(74,6),(75,4),(75,5),(75,6),
(76,4),(76,5),(76,6),(77,4),(77,5),(77,6),(78,4),(78,5),(78,6),(79,4),(79,5),(79,6),(80,4),(80,5),(80,6);

-- Semester 5 students enrolled in courses 5,6,1
INSERT INTO `student_course` (`student_id`, `course_id`) VALUES
(81,5),(81,6),(81,1),(82,5),(82,6),(82,1),(83,5),(83,6),(83,1),(84,5),(84,6),(84,1),(85,5),(85,6),(85,1),
(86,5),(86,6),(86,1),(87,5),(87,6),(87,1),(88,5),(88,6),(88,1),(89,5),(89,6),(89,1),(90,5),(90,6),(90,1),
(91,5),(91,6),(91,1),(92,5),(92,6),(92,1),(93,5),(93,6),(93,1),(94,5),(94,6),(94,1),(95,5),(95,6),(95,1),
(96,5),(96,6),(96,1),(97,5),(97,6),(97,1),(98,5),(98,6),(98,1),(99,5),(99,6),(99,1),(100,5),(100,6),(100,1);

-- Semester 6 students enrolled in courses 6,1,2
INSERT INTO `student_course` (`student_id`, `course_id`) VALUES
(101,6),(101,1),(101,2),(102,6),(102,1),(102,2),(103,6),(103,1),(103,2),(104,6),(104,1),(104,2),(105,6),(105,1),(105,2),
(106,6),(106,1),(106,2),(107,6),(107,1),(107,2),(108,6),(108,1),(108,2),(109,6),(109,1),(109,2),(110,6),(110,1),(110,2),
(111,6),(111,1),(111,2),(112,6),(112,1),(112,2),(113,6),(113,1),(113,2),(114,6),(114,1),(114,2),(115,6),(115,1),(115,2),
(116,6),(116,1),(116,2),(117,6),(117,1),(117,2),(118,6),(118,1),(118,2),(119,6),(119,1),(119,2),(120,6),(120,1),(120,2);

-- Semester 7 students enrolled in courses 1,2,3
INSERT INTO `student_course` (`student_id`, `course_id`) VALUES
(121,1),(121,2),(121,3),(122,1),(122,2),(122,3),(123,1),(123,2),(123,3),(124,1),(124,2),(124,3),(125,1),(125,2),(125,3),
(126,1),(126,2),(126,3),(127,1),(127,2),(127,3),(128,1),(128,2),(128,3),(129,1),(129,2),(129,3),(130,1),(130,2),(130,3),
(131,1),(131,2),(131,3),(132,1),(132,2),(132,3),(133,1),(133,2),(133,3),(134,1),(134,2),(134,3),(135,1),(135,2),(135,3),
(136,1),(136,2),(136,3),(137,1),(137,2),(137,3),(138,1),(138,2),(138,3),(139,1),(139,2),(139,3),(140,1),(140,2),(140,3);

-- Semester 8 students enrolled in courses 2,3,4
INSERT INTO `student_course` (`student_id`, `course_id`) VALUES
(141,2),(141,3),(141,4),(142,2),(142,3),(142,4),(143,2),(143,3),(143,4),(144,2),(144,3),(144,4),(145,2),(145,3),(145,4),
(146,2),(146,3),(146,4),(147,2),(147,3),(147,4),(148,2),(148,3),(148,4),(149,2),(149,3),(149,4),(150,2),(150,3),(150,4),
(151,2),(151,3),(151,4),(152,2),(152,3),(152,4),(153,2),(153,3),(153,4),(154,2),(154,3),(154,4),(155,2),(155,3),(155,4),
(156,2),(156,3),(156,4),(157,2),(157,3),(157,4),(158,2),(158,3),(158,4),(159,2),(159,3),(159,4),(160,2),(160,3),(160,4);

-- ============================================================================
-- COMMIT TRANSACTION
-- ============================================================================
SET FOREIGN_KEY_CHECKS = 1;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

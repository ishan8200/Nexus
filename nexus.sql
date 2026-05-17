-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 16, 2026 at 05:25 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `nexus`
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `active_assignments_view`
-- (See below for the actual view)
--
CREATE TABLE `active_assignments_view` (
`assignment_id` int(11)
,`task_id` int(11)
,`task_title` varchar(255)
,`description` text
,`wage` decimal(10,2)
,`wage_type` enum('fixed','hourly')
,`deadline` date
,`priority` enum('low','medium','high','urgent')
,`worker_id` int(11)
,`worker_name` varchar(100)
,`worker_email` varchar(100)
,`status` enum('accepted','in_progress','submitted','approved','rejected','cancelled')
,`assigned_at` timestamp
,`submitted_at` timestamp
,`completed_at` timestamp
,`quality_rating` int(11)
,`hours_worked` decimal(5,2)
,`days_remaining` int(7)
,`progress_status` varchar(14)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `admin_dashboard_view`
-- (See below for the actual view)
--
CREATE TABLE `admin_dashboard_view` (
`total_workers` bigint(21)
,`active_workers` bigint(21)
,`total_tasks` bigint(21)
,`completed_tasks` bigint(21)
,`open_tasks` bigint(21)
,`in_progress_tasks` bigint(21)
,`pending_submissions` bigint(21)
,`pending_wages` decimal(32,2)
,`paid_wages` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('info','success','warning','error') DEFAULT 'info',
  `reference_id` int(11) DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `reference_id`, `reference_type`, `created_at`) VALUES
(1, 2, 'New Task Assigned', 'You have been assigned to: Neural Engine', 'info', 1, 'task', '2026-05-13 07:46:58'),
(2, 2, 'New Task Assigned', 'You have been assigned to: Neural Engine', 'info', 1, 'task', '2026-05-13 07:46:58'),
(3, 1, 'Work Submitted', 'Worker has submitted work for task: 1', 'info', 1, 'submission', '2026-05-13 07:47:21'),
(4, 2, 'New Task Assigned', 'You have been assigned to: Design Database Schema', 'info', 2, 'task', '2026-05-14 04:11:53'),
(5, 2, 'New Task Assigned', 'You have been assigned to: Design Database Schema', 'info', 2, 'task', '2026-05-14 04:11:53'),
(6, 1, 'Work Submitted', 'Worker has submitted work for task: 2', 'info', 2, 'submission', '2026-05-14 04:12:18'),
(7, 2, 'Task Approved', 'Your work has been approved! Rating: 5/5', 'success', 2, 'task', '2026-05-14 04:13:29'),
(8, 2, 'Task Approved', 'Your work has been approved! Rating: 5/5', 'success', 1, 'task', '2026-05-14 08:32:25'),
(9, 2, 'New Task Assigned', 'You have been assigned to: Implement Real-time Notifications', 'info', 7, 'task', '2026-05-15 02:41:02'),
(10, 2, 'New Task Assigned', 'You have been assigned to: Implement Real-time Notifications', 'info', 7, 'task', '2026-05-15 02:41:02'),
(11, 2, 'New Task Assigned', 'You have been assigned to: Performance Testing', 'info', 10, 'task', '2026-05-15 02:41:18'),
(12, 2, 'New Task Assigned', 'You have been assigned to: Performance Testing', 'info', 10, 'task', '2026-05-15 02:41:18'),
(13, 1, 'Work Submitted', 'Worker has submitted work for task: 7', 'info', 7, 'submission', '2026-05-15 03:59:12'),
(14, 2, 'Task Approved', 'Your work has been approved! Rating: 5/5', 'success', 7, 'task', '2026-05-15 03:59:52');

-- --------------------------------------------------------

--
-- Table structure for table `payment_history`
--

CREATE TABLE `payment_history` (
  `id` int(11) NOT NULL,
  `worker_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_date` date NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `transaction_id` varchar(100) DEFAULT NULL,
  `status` enum('pending','completed','failed','refunded') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `site_settings`
--

CREATE TABLE `site_settings` (
  `id` int(11) NOT NULL,
  `config_key` varchar(100) NOT NULL,
  `config_value` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `site_settings`
--

INSERT INTO `site_settings` (`id`, `config_key`, `config_value`, `updated_at`) VALUES
(1, 'home_hero_title', 'NEXT-GEN OPERATIONAL NEXUS FOR MODERN TEAMS', '2026-05-13 07:20:42'),
(2, 'home_hero_subtitle', 'A raw, structural platform designed for high-velocity project management. No fluff, just pure architectural logic for builders.', '2026-05-13 07:20:42'),
(3, 'about_title', 'THE NEXUS VISION', '2026-05-13 07:20:42'),
(4, 'about_content', 'Nexus was engineered to bridge the gap between abstract strategy and concrete execution. We believe in high-fidelity operational transparency.', '2026-05-13 07:20:42'),
(5, 'contact_email', 'service@nexus.com', '2026-05-13 07:56:08'),
(6, 'contact_phone', '+977 1 4445556', '2026-05-13 07:20:42'),
(7, 'contact_address', 'KamalPokhari, Kathmandu, Nepal', '2026-05-13 07:54:17'),
(8, 'maintenance_mode', 'false', '2026-05-13 07:20:42'),
(9, 'registration_enabled', 'true', '2026-05-13 07:20:42'),
(10, 'system_announcement', 'Hello', '2026-05-13 07:54:42'),
(11, 'social_facebook', 'https://facebook.com/nexus', '2026-05-13 07:20:42'),
(12, 'social_twitter', 'https://twitter.com/nexus', '2026-05-13 07:20:42'),
(13, 'social_linkedin', 'https://linkedin.com/company/nexus', '2026-05-13 07:20:42'),
(14, 'social_github', 'https://github.com/nexus-works', '2026-05-13 07:20:42'),
(15, 'site_logo_url', '/images/Nexuslogo_1.jpg', '2026-05-13 07:20:42');

-- --------------------------------------------------------

--
-- Table structure for table `skills`
--

CREATE TABLE `skills` (
  `id` int(11) NOT NULL,
  `skill_name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `skills`
--

INSERT INTO `skills` (`id`, `skill_name`, `category`, `created_at`) VALUES
(1, 'Web Design', 'Design', '2026-05-03 23:50:56'),
(2, 'UI/UX', 'Design', '2026-05-03 23:50:56'),
(3, 'Figma', 'Design', '2026-05-03 23:50:56'),
(4, 'Graphic Design', 'Design', '2026-05-03 23:50:56'),
(5, 'Content Writing', 'Writing', '2026-05-03 23:50:56'),
(6, 'SEO', 'Marketing', '2026-05-03 23:50:56'),
(7, 'Blogging', 'Writing', '2026-05-03 23:50:56'),
(8, 'PHP', 'Development', '2026-05-03 23:50:56'),
(9, 'WordPress', 'Development', '2026-05-03 23:50:56'),
(10, 'MySQL', 'Development', '2026-05-03 23:50:56'),
(11, 'JavaScript', 'Development', '2026-05-03 23:50:56'),
(12, 'React', 'Development', '2026-05-03 23:50:56'),
(13, 'Python', 'Development', '2026-05-03 23:50:56'),
(14, 'Social Media', 'Marketing', '2026-05-03 23:50:56'),
(15, 'Data Entry', 'Data Entry', '2026-05-03 23:50:56'),
(16, 'QA Testing', 'QA', '2026-05-03 23:50:56'),
(17, 'Project Management', 'Administrative', '2026-05-03 23:50:56'),
(18, 'Customer Service', 'Administrative', '2026-05-03 23:50:56');

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `wage` decimal(10,2) NOT NULL,
  `wage_type` enum('fixed','hourly') DEFAULT 'fixed',
  `deadline` date NOT NULL,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `recurrence` enum('none','daily','weekly','monthly') DEFAULT 'none',
  `status` enum('open','in-progress','pending','completed','cancelled') DEFAULT 'open',
  `assigned_to` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `estimated_hours` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `title`, `description`, `wage`, `wage_type`, `deadline`, `priority`, `recurrence`, `status`, `assigned_to`, `created_by`, `category`, `estimated_hours`, `created_at`, `updated_at`) VALUES
(1, 'Neural Engine', 'Create a NPL', 50000.00, 'fixed', '2026-05-12', 'medium', 'none', 'completed', 2, 1, 'General', 10, '2026-05-12 05:57:01', '2026-05-16 12:36:33'),
(2, 'Design Database Schema', 'Create comprehensive database schema for the new project management system including all relationships and indexes\'', 5000.00, 'fixed', '2026-05-10', 'medium', 'none', 'completed', 2, 3, 'Development', 0, '2026-05-14 03:30:53', '2026-05-14 04:13:29'),
(3, 'Implement Authentication API', 'Develop JWT-based authentication endpoints for user login, registration, and password reset', 7500.00, 'fixed', '2026-05-23', 'low', 'none', 'open', NULL, 3, 'Development', 0, '2026-05-14 03:31:52', '2026-05-14 04:06:04'),
(4, 'Create Landing Page UI', 'Build responsive landing page with hero section, features grid, and call-to-action buttons', 8000.00, 'fixed', '2026-05-20', 'low', 'none', 'open', NULL, 3, 'Design', 5, '2026-05-14 03:33:07', '2026-05-14 04:17:21'),
(5, 'Setup CI/CD Pipeline', 'Configure GitHub Actions for automated testing and deployment to staging environment', 5000.00, 'fixed', '2026-05-22', 'medium', 'none', 'open', NULL, 3, 'General', 0, '2026-05-14 03:34:08', '2026-05-14 03:34:08'),
(6, 'Write API Documentation', 'Create comprehensive Swagger/OpenAPI documentation for all backend endpoints', 50.00, 'hourly', '2026-05-20', 'high', 'none', 'open', NULL, 3, 'General', 0, '2026-05-14 03:34:36', '2026-05-14 03:34:36'),
(7, 'Implement Real-time Notifications', 'Add WebSocket support for live notifications and real-time updates across the platform', 85.00, 'hourly', '2026-05-16', 'low', 'none', 'completed', 2, 3, 'General', 0, '2026-05-14 03:35:31', '2026-05-15 03:59:52'),
(8, 'Design Mobile Responsive Layout', 'Ensure all pages are fully responsive and work seamlessly on tablets and mobile devices', 100.00, 'hourly', '2026-05-22', 'urgent', 'none', 'open', NULL, 3, 'General', 0, '2026-05-14 03:36:59', '2026-05-14 03:36:59'),
(11, 'Database Backup Automation', 'Set up automated database backup schedules and retention policies', 3800.00, 'fixed', '2026-05-23', 'low', 'none', 'open', NULL, 3, 'Development', 5, '2026-05-16 10:31:27', '2026-05-16 10:31:27');

--
-- Triggers `tasks`
--
DELIMITER $$
CREATE TRIGGER `task_assigned_notification` AFTER UPDATE ON `tasks` FOR EACH ROW BEGIN
    IF NEW.assigned_to IS NOT NULL AND OLD.assigned_to IS NULL THEN
        INSERT INTO notifications (user_id, title, message, type, reference_id, reference_type)
        VALUES (NEW.assigned_to, 'New Task Assigned', CONCAT('You have been assigned to: ', NEW.title), 'info', NEW.id, 'task');
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_worker_stats` AFTER UPDATE ON `tasks` FOR EACH ROW BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE users 
        SET tasks_completed = tasks_completed + 1
        WHERE id = NEW.assigned_to;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `task_assignments`
--

CREATE TABLE `task_assignments` (
  `id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `worker_id` int(11) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('accepted','in_progress','submitted','approved','rejected','cancelled') DEFAULT 'accepted',
  `submitted_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `quality_rating` int(11) DEFAULT NULL,
  `admin_feedback` text DEFAULT NULL,
  `submission_text` text DEFAULT NULL,
  `attachment_path` text DEFAULT NULL,
  `hours_worked` decimal(5,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `task_assignments`
--

INSERT INTO `task_assignments` (`id`, `task_id`, `worker_id`, `assigned_at`, `status`, `submitted_at`, `completed_at`, `quality_rating`, `admin_feedback`, `submission_text`, `attachment_path`, `hours_worked`) VALUES
(1, 1, 2, '2026-05-13 07:46:58', 'approved', '2026-05-13 07:47:21', '2026-05-14 08:32:25', 5, 'Approved via Admin ', 'done', 'fda4d5b8-be66-4c07-85d4-53a26b851b98.png,20dad1b3-2f5b-4ece-9d45-957a393f3121.csv,3aa09e79-16f0-4054-9ae3-5f1f4fa3528d.csv', 24.00),
(2, 2, 2, '2026-05-14 04:11:53', 'approved', '2026-05-14 04:12:18', '2026-05-14 04:13:29', 5, 'Approved via Admin ', 'Done', '80d50ada-6001-4351-bb04-d5e862de8e61.sql', 4.00),
(3, 7, 2, '2026-05-15 02:41:02', 'approved', '2026-05-15 03:59:12', '2026-05-15 03:59:52', 5, 'Approved via Admin Dashboard', 'Done', NULL, 0.00);

--
-- Triggers `task_assignments`
--
DELIMITER $$
CREATE TRIGGER `update_task_status_on_approval` AFTER UPDATE ON `task_assignments` FOR EACH ROW BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        UPDATE tasks SET status = 'completed' WHERE id = NEW.task_id;
    ELSEIF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
        UPDATE tasks SET status = 'open', assigned_to = NULL WHERE id = NEW.task_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `task_submissions`
--

CREATE TABLE `task_submissions` (
  `id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `worker_id` int(11) NOT NULL,
  `submission_text` text NOT NULL,
  `attachment_path` text DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `hours_worked` decimal(5,2) DEFAULT 0.00,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `rating` int(11) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `task_submissions`
--

INSERT INTO `task_submissions` (`id`, `task_id`, `worker_id`, `submission_text`, `attachment_path`, `status`, `hours_worked`, `submitted_at`, `reviewed_at`, `reviewed_by`) VALUES
(1, 1, 2, 'done', 'fda4d5b8-be66-4c07-85d4-53a26b851b98.png,20dad1b3-2f5b-4ece-9d45-957a393f3121.csv,3aa09e79-16f0-4054-9ae3-5f1f4fa3528d.csv', 'pending', 24.00, '2026-05-13 07:47:21', NULL, NULL),
(2, 2, 2, 'Done', '80d50ada-6001-4351-bb04-d5e862de8e61.sql', 'pending', 4.00, '2026-05-14 04:12:18', NULL, NULL),
(3, 7, 2, 'Done', NULL, 'pending', 0.00, '2026-05-15 03:59:12', NULL, NULL);

--
-- Triggers `task_submissions`
--
DELIMITER $$
CREATE TRIGGER `submission_review_notification` AFTER UPDATE ON `task_submissions` FOR EACH ROW BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO notifications (user_id, title, message, type, reference_id, reference_type)
        VALUES (
            NEW.worker_id, 
            CONCAT('Submission ', NEW.status), 
            CONCAT('Your submission for task has been ', NEW.status),
            CASE WHEN NEW.status = 'approved' THEN 'success' ELSE 'warning' END,
            NEW.id, 
            'submission'
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role` enum('admin','worker') DEFAULT 'worker',
  `status` enum('pending','approved','rejected','blocked') DEFAULT 'pending',
  `failed_attempts` int(11) DEFAULT 0,
  `profile_pic` varchar(255) DEFAULT NULL,
  `skills` text DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT 0.00,
  `total_earned` decimal(10,2) DEFAULT 0.00,
  `tasks_completed` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `full_name`, `phone`, `role`, `status`, `failed_attempts`, `profile_pic`, `skills`, `rating`, `total_earned`, `tasks_completed`, `created_at`, `last_login`, `updated_at`) VALUES
(1, 'ishan123', 'ishan@nexus.com', '$2a$10$fGvNbXLBbPW2CiblbZWnduyPkRFp/mdo1zTRj50EypAhq2g/bD2CS', 'Ishan Maharjan', '+9779864478569', 'admin', 'approved', 0, NULL, NULL, 0.00, 0.00, 0, '2026-05-12 05:55:25', '2026-05-16 12:35:55', '2026-05-16 12:35:55'),
(2, 'surab13', 'surab820@nexus.com', '$2a$10$vtuBijoi90PdV4ZbdOHyxOeNSA9BywTiqEbW8nFLL5GlTJCLLRhBC', 'Surab Maharjan', '+9779864478567', 'worker', 'approved', 0, '25ecaa2e-d094-4a0a-b2ff-838bafae4ac8.png', 'JavaScript, PHP, Python, UI/UX', 4.00, 55085.00, 6, '2026-05-12 05:57:52', '2026-05-16 14:58:31', '2026-05-16 14:58:31'),
(3, 'admin', 'admin@nexus.com', '$2a$10$cL5hC8tyDsFvEylN5WuN1e72QNSHQYl9oKp7IgAYEvfxctpUDsrfe', 'Admin', '+9779864478568', 'admin', 'approved', 0, '6ae62a24-f587-4fec-bd78-397ab12083dc.JPG', NULL, 0.00, 0.00, 0, '2026-05-14 03:16:08', '2026-05-16 14:44:05', '2026-05-16 14:50:08'),
(4, 'sabinkc', 'sabinkc@nexus.com', '$2a$10$FURJ8iSdBycyNWk9zG7Dcu/X.tluGdO3cNcI4sdKeC7LrbjKVQFI.', 'Sabin Kc', '+9779864478566', 'worker', 'approved', 0, NULL, NULL, 4.00, 0.00, 0, '2026-05-16 08:02:35', NULL, '2026-05-16 12:46:38'),
(5, 'admin1', 'admin1@nexus.com', '$2a$10$ligv/ozO5WDszSWGNGl1p.tX0GPv8K1sWLdarzV3IjOt5MFW9bOOy', 'Admin1', '+9779864478577', 'admin', 'approved', 0, NULL, NULL, 0.00, 0.00, 0, '2026-05-16 08:06:37', '2026-05-16 14:58:07', '2026-05-16 14:58:07');

-- --------------------------------------------------------

--
-- Table structure for table `wages`
--

CREATE TABLE `wages` (
  `id` int(11) NOT NULL,
  `worker_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `submission_id` int(11) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','paid','cancelled') DEFAULT 'pending',
  `paid_at` timestamp NULL DEFAULT NULL,
  `paid_by` int(11) DEFAULT NULL,
  `transaction_id` varchar(100) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `wages`
--

INSERT INTO `wages` (`id`, `worker_id`, `task_id`, `submission_id`, `amount`, `status`, `paid_at`, `paid_by`, `transaction_id`, `payment_method`, `created_at`, `updated_at`) VALUES
(1, 2, 2, NULL, 5000.00, 'paid', '2026-05-14 09:05:28', 3, 'TXN-46B6BAC0', 'System Transfer', '2026-05-14 04:13:29', '2026-05-14 09:05:28'),
(2, 2, 1, NULL, 50000.00, 'paid', '2026-05-14 08:32:41', 1, 'TXN-22EF7D18', 'System Transfer', '2026-05-14 08:32:25', '2026-05-14 08:32:41'),
(3, 2, 7, NULL, 85.00, 'paid', '2026-05-15 04:00:25', 3, 'TXN-9F645DA0', 'System Transfer', '2026-05-15 03:59:52', '2026-05-15 04:00:25');

-- --------------------------------------------------------

--
-- Stand-in structure for view `worker_assignment_stats`
-- (See below for the actual view)
--
CREATE TABLE `worker_assignment_stats` (
`worker_id` int(11)
,`worker_name` varchar(100)
,`total_assignments` bigint(21)
,`completed_tasks` decimal(22,0)
,`pending_review` decimal(22,0)
,`rejected_tasks` decimal(22,0)
,`in_progress_tasks` decimal(22,0)
,`avg_rating` decimal(13,2)
,`total_hours_worked` decimal(27,2)
,`total_earned` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `worker_performance_view`
-- (See below for the actual view)
--
CREATE TABLE `worker_performance_view` (
);

-- --------------------------------------------------------

--
-- Table structure for table `worker_skills`
--

CREATE TABLE `worker_skills` (
  `worker_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL,
  `proficiency_level` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `worker_skills`
--

INSERT INTO `worker_skills` (`worker_id`, `skill_id`, `proficiency_level`, `created_at`) VALUES
(2, 2, 1, '2026-05-15 03:14:49'),
(2, 8, 2, '2026-05-15 03:15:05'),
(2, 11, 2, '2026-05-15 03:15:27'),
(2, 13, 2, '2026-05-15 03:14:58');

-- --------------------------------------------------------

--
-- Structure for view `active_assignments_view`
--
DROP TABLE IF EXISTS `active_assignments_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `active_assignments_view`  AS SELECT `ta`.`id` AS `assignment_id`, `ta`.`task_id` AS `task_id`, `t`.`title` AS `task_title`, `t`.`description` AS `description`, `t`.`wage` AS `wage`, `t`.`wage_type` AS `wage_type`, `t`.`deadline` AS `deadline`, `t`.`priority` AS `priority`, `ta`.`worker_id` AS `worker_id`, `u`.`full_name` AS `worker_name`, `u`.`email` AS `worker_email`, `ta`.`status` AS `status`, `ta`.`assigned_at` AS `assigned_at`, `ta`.`submitted_at` AS `submitted_at`, `ta`.`completed_at` AS `completed_at`, `ta`.`quality_rating` AS `quality_rating`, `ta`.`hours_worked` AS `hours_worked`, to_days(`t`.`deadline`) - to_days(current_timestamp()) AS `days_remaining`, CASE WHEN `ta`.`status` = 'submitted' THEN 'Pending Review' WHEN `ta`.`status` = 'approved' THEN 'Completed' WHEN `ta`.`status` = 'rejected' THEN 'Needs Rework' WHEN `t`.`deadline` < current_timestamp() AND `ta`.`status` not in ('approved','rejected','cancelled') THEN 'Overdue' ELSE 'Active' END AS `progress_status` FROM ((`task_assignments` `ta` join `tasks` `t` on(`ta`.`task_id` = `t`.`id`)) join `users` `u` on(`ta`.`worker_id` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `admin_dashboard_view`
--
DROP TABLE IF EXISTS `admin_dashboard_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `admin_dashboard_view`  AS SELECT (select count(0) from `users` where `users`.`role` = 'worker') AS `total_workers`, (select count(0) from `users` where `users`.`role` = 'worker' and `users`.`status` = 'approved') AS `active_workers`, (select count(0) from `tasks`) AS `total_tasks`, (select count(0) from `tasks` where `tasks`.`status` = 'completed') AS `completed_tasks`, (select count(0) from `tasks` where `tasks`.`status` = 'open') AS `open_tasks`, (select count(0) from `tasks` where `tasks`.`status` = 'in-progress') AS `in_progress_tasks`, (select count(0) from `task_submissions` where `task_submissions`.`status` = 'pending') AS `pending_submissions`, (select coalesce(sum(`wages`.`amount`),0) from `wages` where `wages`.`status` = 'pending') AS `pending_wages`, (select coalesce(sum(`wages`.`amount`),0) from `wages` where `wages`.`status` = 'paid') AS `paid_wages` ;

-- --------------------------------------------------------

--
-- Structure for view `worker_assignment_stats`
--
DROP TABLE IF EXISTS `worker_assignment_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `worker_assignment_stats`  AS SELECT `ta`.`worker_id` AS `worker_id`, `u`.`full_name` AS `worker_name`, count(`ta`.`id`) AS `total_assignments`, sum(case when `ta`.`status` = 'approved' then 1 else 0 end) AS `completed_tasks`, sum(case when `ta`.`status` = 'submitted' then 1 else 0 end) AS `pending_review`, sum(case when `ta`.`status` = 'rejected' then 1 else 0 end) AS `rejected_tasks`, sum(case when `ta`.`status` = 'in_progress' then 1 else 0 end) AS `in_progress_tasks`, round(avg(case when `ta`.`quality_rating` is not null then `ta`.`quality_rating` end),2) AS `avg_rating`, sum(`ta`.`hours_worked`) AS `total_hours_worked`, sum(case when `ta`.`status` = 'approved' then `t`.`wage` else 0 end) AS `total_earned` FROM ((`task_assignments` `ta` join `users` `u` on(`ta`.`worker_id` = `u`.`id`)) join `tasks` `t` on(`ta`.`task_id` = `t`.`id`)) WHERE `u`.`role` = 'worker' GROUP BY `ta`.`worker_id`, `u`.`full_name` ;

-- --------------------------------------------------------

--
-- Structure for view `worker_performance_view`
--
DROP TABLE IF EXISTS `worker_performance_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `worker_performance_view`  AS SELECT `u`.`id` AS `worker_id`, `u`.`full_name` AS `full_name`, `u`.`email` AS `email`, `u`.`rating` AS `rating`, `u`.`tasks_completed` AS `tasks_completed`, `u`.`total_earned` AS `total_earned`, count(distinct `t`.`id`) AS `assigned_tasks`, count(distinct `ts`.`id`) AS `submissions_made`, avg(`ts`.`rating`) AS `avg_rating` FROM ((`users` `u` left join `tasks` `t` on(`t`.`assigned_to` = `u`.`id`)) left join `task_submissions` `ts` on(`ts`.`worker_id` = `u`.`id`)) WHERE `u`.`role` = 'worker' GROUP BY `u`.`id` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `payment_history`
--
ALTER TABLE `payment_history`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`),
  ADD KEY `idx_worker_id` (`worker_id`),
  ADD KEY `idx_payment_date` (`payment_date`);

--
-- Indexes for table `site_settings`
--
ALTER TABLE `site_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `config_key` (`config_key`);

--
-- Indexes for table `skills`
--
ALTER TABLE `skills`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `skill_name` (`skill_name`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_assigned_to` (`assigned_to`),
  ADD KEY `idx_deadline` (`deadline`),
  ADD KEY `idx_priority` (`priority`);

--
-- Indexes for table `task_assignments`
--
ALTER TABLE `task_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_task_worker` (`task_id`,`worker_id`),
  ADD KEY `idx_task_id` (`task_id`),
  ADD KEY `idx_worker_id` (`worker_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `task_submissions`
--
ALTER TABLE `task_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_submissions_task_worker` (`task_id`,`worker_id`),
  ADD KEY `reviewed_by` (`reviewed_by`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_task_id` (`task_id`),
  ADD KEY `idx_worker_id` (`worker_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `wages`
--
ALTER TABLE `wages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `task_id` (`task_id`),
  ADD KEY `submission_id` (`submission_id`),
  ADD KEY `paid_by` (`paid_by`),
  ADD KEY `idx_worker_id` (`worker_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `worker_skills`
--
ALTER TABLE `worker_skills`
  ADD PRIMARY KEY (`worker_id`,`skill_id`),
  ADD KEY `skill_id` (`skill_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `payment_history`
--
ALTER TABLE `payment_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `site_settings`
--
ALTER TABLE `site_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `skills`
--
ALTER TABLE `skills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `task_assignments`
--
ALTER TABLE `task_assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `task_submissions`
--
ALTER TABLE `task_submissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `wages`
--
ALTER TABLE `wages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_history`
--
ALTER TABLE `payment_history`
  ADD CONSTRAINT `payment_history_ibfk_1` FOREIGN KEY (`worker_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `task_assignments`
--
ALTER TABLE `task_assignments`
  ADD CONSTRAINT `fk_task_assignments_task` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_task_assignments_worker` FOREIGN KEY (`worker_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `task_submissions`
--
ALTER TABLE `task_submissions`
  ADD CONSTRAINT `task_submissions_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_submissions_ibfk_2` FOREIGN KEY (`worker_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `task_submissions_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `wages`
--
ALTER TABLE `wages`
  ADD CONSTRAINT `wages_ibfk_1` FOREIGN KEY (`worker_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `wages_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`),
  ADD CONSTRAINT `wages_ibfk_3` FOREIGN KEY (`submission_id`) REFERENCES `task_submissions` (`id`),
  ADD CONSTRAINT `wages_ibfk_4` FOREIGN KEY (`paid_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `worker_skills`
--
ALTER TABLE `worker_skills`
  ADD CONSTRAINT `worker_skills_ibfk_1` FOREIGN KEY (`worker_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `worker_skills_ibfk_2` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

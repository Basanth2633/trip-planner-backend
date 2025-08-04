create database Team_3;

use Team_3;

-- Trip Planner MySQL Schema

-- Drop tables if they exist to avoid conflicts
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS `address`;
DROP TABLE IF EXISTS `credit_card`;
DROP TABLE IF EXISTS `trip`;
DROP TABLE IF EXISTS `attraction`;
DROP TABLE IF EXISTS `hours_of_operation`;
DROP TABLE IF EXISTS `reserved_attraction`;
DROP TABLE IF EXISTS `paid_attraction`;
DROP TABLE IF EXISTS `public_transportation`;
DROP TABLE IF EXISTS `review`;
DROP TABLE IF EXISTS `activity`;
DROP TABLE IF EXISTS `time_slot`;
DROP TABLE IF EXISTS `plans`;
DROP TABLE IF EXISTS `owns`;
DROP TABLE IF EXISTS `writes`;
DROP TABLE IF EXISTS `at`;
DROP TABLE IF EXISTS `contains`;
DROP TABLE IF EXISTS `paid_with`;
DROP TABLE IF EXISTS `rates`;
DROP TABLE IF EXISTS `reserves`;
DROP TABLE IF EXISTS `nearest_to`;
DROP TABLE IF EXISTS `has`;

SET FOREIGN_KEY_CHECKS = 1;

-- Create Address table
CREATE TABLE `address` (
    `address_id` INT AUTO_INCREMENT PRIMARY KEY,
    `number` VARCHAR(20) NOT NULL,
    `street` VARCHAR(100) NOT NULL,
    `city` VARCHAR(50) NOT NULL,
    `state` VARCHAR(50),
    `zip` VARCHAR(20),
    `country` VARCHAR(50) NOT NULL,
    UNIQUE KEY `address_unique` (`number`, `street`, `city`, `state`, `zip`, `country`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create User table
CREATE TABLE `user` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `is_admin` BOOLEAN DEFAULT FALSE,
    `suspended` BOOLEAN DEFAULT FALSE,
    `address_id` INT,
    FOREIGN KEY (`address_id`) REFERENCES `address` (`address_id`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Trip table
CREATE TABLE `trip` (
    `trip_id` INT AUTO_INCREMENT PRIMARY KEY,
    `city` VARCHAR(100) NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `booked` BOOLEAN DEFAULT FALSE,
    `start_date_time` DATETIME,
    `end_date_time` DATETIME,
    `total_cost` DECIMAL(10, 2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Attraction table (Base table for attraction types)
CREATE TABLE `attraction` (
    `attraction_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `address_id` INT,
    FOREIGN KEY (`address_id`) REFERENCES `address` (`address_id`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Hours of Operation table
CREATE TABLE `hours_of_operation` (
    `hours_id` INT AUTO_INCREMENT PRIMARY KEY,
    `day_of_week` ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    `opening_time` TIME,
    `closing_time` TIME,
    `attraction_id` INT NOT NULL,
    FOREIGN KEY (`attraction_id`) REFERENCES `attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Reserved Attraction table (Specialization of Attraction)
CREATE TABLE `reserved_attraction` (
    `attraction_id` INT PRIMARY KEY,
    FOREIGN KEY (`attraction_id`) REFERENCES `attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Paid Attraction table (Specialization of Attraction)
CREATE TABLE `paid_attraction` (
    `attraction_id` INT PRIMARY KEY,
    `price` DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (`attraction_id`) REFERENCES `attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Public Transportation table (Specialization of Attraction)
CREATE TABLE `public_transportation` (
    `attraction_id` INT PRIMARY KEY,
    `transport_name` VARCHAR(100) NOT NULL,
    `transport_address_id` INT,
    FOREIGN KEY (`attraction_id`) REFERENCES `attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`transport_address_id`) REFERENCES `address` (`address_id`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Credit Card table
CREATE TABLE `credit_card` (
    `card_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `cc_number` VARCHAR(255) NOT NULL, -- Encrypted/hashed
    `address_id` INT,
    `expiry` DATE NOT NULL,
    `cvv` VARCHAR(255) NOT NULL, -- Encrypted/hashed
    FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`address_id`) REFERENCES `address` (`address_id`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Review table
CREATE TABLE `review` (
    `review_id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(100) NOT NULL,
    `body` TEXT,
    `date` DATE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Activity table
CREATE TABLE `activity` (
    `activity_id` INT AUTO_INCREMENT PRIMARY KEY,
    `start_date_time` DATETIME NOT NULL,
    `end_date_time` DATETIME NOT NULL,
    `number_in_party` INT DEFAULT 1,
    `reservation_number` VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Time Slot table (Weak entity)
CREATE TABLE `time_slot` (
    `time_slot_id` INT NOT NULL,
    `attraction_id` INT NOT NULL,
    `start_date_time` DATETIME NOT NULL,
    `end_date_time` DATETIME NOT NULL,
    `quantity` INT NOT NULL DEFAULT 1,
    PRIMARY KEY (`time_slot_id`, `attraction_id`),
    FOREIGN KEY (`attraction_id`) REFERENCES `reserved_attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Plans relationship (User to Trip)
CREATE TABLE `plans` (
    `user_id` INT NOT NULL,
    `trip_id` INT NOT NULL,
    PRIMARY KEY (`user_id`, `trip_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`trip_id`) REFERENCES `trip` (`trip_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Owns relationship (User to Trip)
CREATE TABLE `owns` (
    `user_id` INT NOT NULL,
    `trip_id` INT NOT NULL,
    PRIMARY KEY (`user_id`, `trip_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`trip_id`) REFERENCES `trip` (`trip_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Writes relationship (User to Review)
CREATE TABLE `writes` (
    `user_id` INT NOT NULL,
    `review_id` INT NOT NULL,
    PRIMARY KEY (`user_id`, `review_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`review_id`) REFERENCES `review` (`review_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create At relationship (Review to Attraction)
CREATE TABLE `at` (
    `review_id` INT NOT NULL,
    `attraction_id` INT NOT NULL,
    PRIMARY KEY (`review_id`, `attraction_id`),
    FOREIGN KEY (`review_id`) REFERENCES `review` (`review_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`attraction_id`) REFERENCES `attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Contains relationship (Trip to Activity)
CREATE TABLE `contains` (
    `trip_id` INT NOT NULL,
    `activity_id` INT NOT NULL,
    PRIMARY KEY (`trip_id`, `activity_id`),
    FOREIGN KEY (`trip_id`) REFERENCES `trip` (`trip_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create PaidWith relationship (Trip to CreditCard)
CREATE TABLE `paid_with` (
    `trip_id` INT NOT NULL,
    `card_id` INT NOT NULL,
    PRIMARY KEY (`trip_id`, `card_id`),
    FOREIGN KEY (`trip_id`) REFERENCES `trip` (`trip_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`card_id`) REFERENCES `credit_card` (`card_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Rates relationship (Review to Attraction with rating)
CREATE TABLE `rates` (
    `review_id` INT NOT NULL,
    `attraction_id` INT NOT NULL,
    `rating` INT NOT NULL,
    PRIMARY KEY (`review_id`, `attraction_id`),
    FOREIGN KEY (`review_id`) REFERENCES `review` (`review_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`attraction_id`) REFERENCES `attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Reserves relationship (Activity to TimeSlot)
CREATE TABLE `reserves` (
    `activity_id` INT NOT NULL,
    `time_slot_id` INT NOT NULL,
    `attraction_id` INT NOT NULL,
    PRIMARY KEY (`activity_id`, `time_slot_id`, `attraction_id`),
    FOREIGN KEY (`activity_id`) REFERENCES `activity` (`activity_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`time_slot_id`, `attraction_id`) REFERENCES `time_slot` (`time_slot_id`, `attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create NearestTo relationship (Attraction to PublicTransportation)
CREATE TABLE `nearest_to` (
    `attraction_id` INT NOT NULL,
    `transport_id` INT NOT NULL,
    PRIMARY KEY (`attraction_id`, `transport_id`),
    FOREIGN KEY (`attraction_id`) REFERENCES `attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`transport_id`) REFERENCES `public_transportation` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Has relationship (ReservedAttraction to TimeSlot)
CREATE TABLE `has` (
    `attraction_id` INT NOT NULL,
    `time_slot_id` INT NOT NULL,
    PRIMARY KEY (`attraction_id`, `time_slot_id`),
    FOREIGN KEY (`attraction_id`) REFERENCES `reserved_attraction` (`attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`time_slot_id`, `attraction_id`) REFERENCES `time_slot` (`time_slot_id`, `attraction_id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add some basic constraints and indexes
ALTER TABLE `user` ADD INDEX `idx_user_email` (`email`);
ALTER TABLE `user` ADD INDEX `idx_user_name` (`name`);
ALTER TABLE `trip` ADD INDEX `idx_trip_dates` (`start_date`, `end_date`);
ALTER TABLE `trip` ADD INDEX `idx_trip_city` (`city`);
ALTER TABLE `attraction` ADD INDEX `idx_attraction_name` (`name`);
ALTER TABLE `credit_card` ADD INDEX `idx_card_user` (`user_id`);
ALTER TABLE `activity` ADD INDEX `idx_activity_dates` (`start_date_time`, `end_date_time`);
ALTER TABLE `time_slot` ADD INDEX `idx_slot_dates` (`start_date_time`, `end_date_time`);
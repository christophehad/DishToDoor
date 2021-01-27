-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 25, 2021 at 07:01 PM
-- Server version: 10.4.17-MariaDB
-- PHP Version: 8.0.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dishtodoor`
--

-- --------------------------------------------------------

--
-- Table structure for table `charity_organizations`
--

CREATE TABLE `charity_organizations` (
  `charity_id` int(11) NOT NULL,
  `charity_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `phone` int(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `street` varchar(255) NOT NULL,
  `building` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cook`
--

CREATE TABLE `cook` (
  `cook_id` int(11) NOT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `opening_time` time DEFAULT NULL,
  `closing_time` time DEFAULT NULL,
  `cook_logo` varchar(2083) COLLATE utf8_unicode_ci DEFAULT NULL,
  `exp_delivery_time` time DEFAULT NULL,
  `cook_discount` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delivery_radius` int(255) DEFAULT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cook_cuisine_types`
--

CREATE TABLE `cook_cuisine_types` (
  `cook_id` int(11) NOT NULL,
  `cuisine_type` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cook_delivery`
--

CREATE TABLE `cook_delivery` (
  `cook_id` int(11) NOT NULL,
  `delivery_id` int(11) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cook_donations`
--

CREATE TABLE `cook_donations` (
  `donation_id` int(11) NOT NULL,
  `cook_id` int(11) NOT NULL,
  `charity_id` int(11) NOT NULL,
  `nb_dishes` int(255) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cook_kitchen_pics`
--

CREATE TABLE `cook_kitchen_pics` (
  `cook_id` int(11) NOT NULL,
  `kitchen_pic` varchar(2083) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cook_promocodes`
--

CREATE TABLE `cook_promocodes` (
  `cook_id` int(11) NOT NULL,
  `promocode` int(255) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cook_review`
--

CREATE TABLE `cook_review` (
  `review_id` int(11) NOT NULL,
  `eater_id` int(11) NOT NULL,
  `cook_id` int(11) NOT NULL,
  `review` text NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cook_review_pics`
--

CREATE TABLE `cook_review_pics` (
  `pic_review_id` int(11) NOT NULL,
  `review_id` int(11) NOT NULL,
  `feedback_pic` varchar(2083) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `delivery_service`
--

CREATE TABLE `delivery_service` (
  `delivery_id` int(11) NOT NULL,
  `delivery_name` varchar(255) NOT NULL,
  `is_certified` tinyint(1) NOT NULL,
  `transportation_method` varchar(255) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `dishes`
--

CREATE TABLE `dishes` (
  `dish_id` int(11) NOT NULL,
  `gendish_id` int(11) NOT NULL,
  `cook_id` int(11) NOT NULL,
  `custom_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` int(255) NOT NULL,
  `category` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `label` varchar(2083) DEFAULT NULL,
  `description` varchar(2083) DEFAULT NULL,
  `dish_discount` int(255) DEFAULT NULL,
  `is_combo` tinyint(1) DEFAULT NULL,
  `dish_pic` varchar(2083) DEFAULT NULL,
  `dish_status` varchar(2083) DEFAULT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `dish_ingredients`
--

CREATE TABLE `dish_ingredients` (
  `dish_id` int(11) NOT NULL,
  `ingredient_id` int(11) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `dish_rating`
--

CREATE TABLE `dish_rating` (
  `rating_id` int(11) NOT NULL,
  `eater_id` int(11) NOT NULL,
  `dish_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `dish_to_generic`
--

CREATE TABLE `dish_to_generic` (
  `dish_id` int(11) NOT NULL,
  `gendish_id` int(11) NOT NULL,
  `special` varchar(255) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `eater`
--

CREATE TABLE `eater` (
  `eater_id` int(11) NOT NULL,
  `pickup_radius` int(255) DEFAULT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `eater_allergens`
--

CREATE TABLE `eater_allergens` (
  `eater_id` int(11) NOT NULL,
  `allergen` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `eater_cart`
--

CREATE TABLE `eater_cart` (
  `eater_id` int(11) NOT NULL,
  `dish_id` int(11) NOT NULL,
  `cook_id` int(11) NOT NULL,
  `delivery_availability` tinyint(1) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `eater_dish_order`
--

CREATE TABLE `eater_dish_order` (
  `orders_index` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `dish_id` int(11) NOT NULL,
  `eater_id` int(11) NOT NULL,
  `quantity` int(255) NOT NULL,
  `delivery_method` enum('delivery','takeaway') NOT NULL,
  `date_scheduled_on` datetime DEFAULT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `eater_favorite_dish`
--

CREATE TABLE `eater_favorite_dish` (
  `eater_id` int(11) NOT NULL,
  `dish_id` int(11) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `eater_gendish_feast`
--

CREATE TABLE `eater_gendish_feast` (
  `feast_order_index` int(11) NOT NULL,
  `feast_id` int(11) NOT NULL,
  `gendish_id` int(11) NOT NULL,
  `eater_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `quantity` int(255) NOT NULL,
  `delivery_method` enum('delivery','takeaway') NOT NULL,
  `date_scheduled_on` datetime NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `feast_suggested_cooks`
--

CREATE TABLE `feast_suggested_cooks` (
  `feast_cooks_index` int(11) NOT NULL,
  `feast_id` int(11) NOT NULL,
  `gendish_id` int(11) NOT NULL,
  `cook_id` int(11) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `generic_dishes`
--

CREATE TABLE `generic_dishes` (
  `gendish_id` int(11) NOT NULL,
  `gendish_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `category` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `mean_price` int(11) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `generic_dish_ingredients`
--

CREATE TABLE `generic_dish_ingredients` (
  `gendish_id` int(11) NOT NULL,
  `ingredient_id` int(11) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `ingredients`
--

CREATE TABLE `ingredients` (
  `ingredient_id` int(11) NOT NULL,
  `ingredient_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `order_status`
--

CREATE TABLE `order_status` (
  `order_id` int(11) NOT NULL,
  `prepared_status` varchar(255) NOT NULL,
  `packaged_status` varchar(255) NOT NULL,
  `delivery_id` int(11) NOT NULL,
  `delivery_status` varchar(255) NOT NULL,
  `message` varchar(2038) NOT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `user_account`
--

CREATE TABLE `user_account` (
  `id` int(11) NOT NULL,
  `email` varchar(320) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` enum('COOK','EATER','ADMIN') COLLATE utf8_unicode_ci NOT NULL,
  `password` binary(60) NOT NULL COMMENT 'length for bcrypt hash',
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_profile`
--

CREATE TABLE `user_profile` (
  `id` int(11) NOT NULL,
  `type` enum('COOK','EATER','ADMIN') COLLATE utf8_unicode_ci NOT NULL,
  `first_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `last_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `dob` date DEFAULT NULL,
  `city` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `street` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `building` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `floor` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `_added` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `charity_organizations`
--
ALTER TABLE `charity_organizations`
  ADD PRIMARY KEY (`charity_id`);

--
-- Indexes for table `cook`
--
ALTER TABLE `cook`
  ADD PRIMARY KEY (`cook_id`);

--
-- Indexes for table `cook_cuisine_types`
--
ALTER TABLE `cook_cuisine_types`
  ADD PRIMARY KEY (`cook_id`);

--
-- Indexes for table `cook_delivery`
--
ALTER TABLE `cook_delivery`
  ADD PRIMARY KEY (`cook_id`),
  ADD KEY `delivery_id` (`delivery_id`);

--
-- Indexes for table `cook_donations`
--
ALTER TABLE `cook_donations`
  ADD PRIMARY KEY (`donation_id`),
  ADD KEY `cook_id` (`cook_id`),
  ADD KEY `charity_id` (`charity_id`);

--
-- Indexes for table `cook_kitchen_pics`
--
ALTER TABLE `cook_kitchen_pics`
  ADD PRIMARY KEY (`cook_id`);

--
-- Indexes for table `cook_promocodes`
--
ALTER TABLE `cook_promocodes`
  ADD PRIMARY KEY (`cook_id`);

--
-- Indexes for table `cook_review`
--
ALTER TABLE `cook_review`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `cook_id` (`cook_id`),
  ADD KEY `eater_id` (`eater_id`);

--
-- Indexes for table `cook_review_pics`
--
ALTER TABLE `cook_review_pics`
  ADD PRIMARY KEY (`pic_review_id`),
  ADD KEY `review_id` (`review_id`);

--
-- Indexes for table `delivery_service`
--
ALTER TABLE `delivery_service`
  ADD PRIMARY KEY (`delivery_id`);

--
-- Indexes for table `dishes`
--
ALTER TABLE `dishes`
  ADD PRIMARY KEY (`dish_id`),
  ADD KEY `gendish_id` (`gendish_id`),
  ADD KEY `cook_id` (`cook_id`);

--
-- Indexes for table `dish_ingredients`
--
ALTER TABLE `dish_ingredients`
  ADD PRIMARY KEY (`dish_id`),
  ADD KEY `ingredient_id` (`ingredient_id`);

--
-- Indexes for table `dish_rating`
--
ALTER TABLE `dish_rating`
  ADD PRIMARY KEY (`rating_id`),
  ADD KEY `eater_id` (`eater_id`),
  ADD KEY `dish_id` (`dish_id`);

--
-- Indexes for table `dish_to_generic`
--
ALTER TABLE `dish_to_generic`
  ADD PRIMARY KEY (`dish_id`),
  ADD KEY `gendish_id` (`gendish_id`);

--
-- Indexes for table `eater`
--
ALTER TABLE `eater`
  ADD PRIMARY KEY (`eater_id`);

--
-- Indexes for table `eater_allergens`
--
ALTER TABLE `eater_allergens`
  ADD PRIMARY KEY (`eater_id`),
  ADD UNIQUE KEY `allergen` (`allergen`);

--
-- Indexes for table `eater_cart`
--
ALTER TABLE `eater_cart`
  ADD PRIMARY KEY (`eater_id`),
  ADD UNIQUE KEY `dish_id` (`dish_id`),
  ADD KEY `cook_id` (`cook_id`);

--
-- Indexes for table `eater_dish_order`
--
ALTER TABLE `eater_dish_order`
  ADD PRIMARY KEY (`orders_index`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `dish_id` (`dish_id`),
  ADD KEY `eater_id` (`eater_id`);

--
-- Indexes for table `eater_favorite_dish`
--
ALTER TABLE `eater_favorite_dish`
  ADD PRIMARY KEY (`eater_id`),
  ADD UNIQUE KEY `dish_id` (`dish_id`);

--
-- Indexes for table `eater_gendish_feast`
--
ALTER TABLE `eater_gendish_feast`
  ADD PRIMARY KEY (`feast_order_index`),
  ADD KEY `gendish_id` (`gendish_id`),
  ADD KEY `eater_id` (`eater_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `feast_id` (`feast_id`);

--
-- Indexes for table `feast_suggested_cooks`
--
ALTER TABLE `feast_suggested_cooks`
  ADD PRIMARY KEY (`feast_cooks_index`),
  ADD KEY `feast_id` (`feast_id`),
  ADD KEY `gendish_id` (`gendish_id`),
  ADD KEY `cook_id` (`cook_id`);

--
-- Indexes for table `generic_dishes`
--
ALTER TABLE `generic_dishes`
  ADD PRIMARY KEY (`gendish_id`);

--
-- Indexes for table `generic_dish_ingredients`
--
ALTER TABLE `generic_dish_ingredients`
  ADD PRIMARY KEY (`gendish_id`),
  ADD KEY `ingredient_id` (`ingredient_id`);

--
-- Indexes for table `ingredients`
--
ALTER TABLE `ingredients`
  ADD PRIMARY KEY (`ingredient_id`);

--
-- Indexes for table `order_status`
--
ALTER TABLE `order_status`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `delivery_id` (`delivery_id`);

--
-- Indexes for table `user_account`
--
ALTER TABLE `user_account`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_profile`
--
ALTER TABLE `user_profile`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cook_review_pics`
--
ALTER TABLE `cook_review_pics`
  MODIFY `pic_review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dishes`
--
ALTER TABLE `dishes`
  MODIFY `dish_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dish_rating`
--
ALTER TABLE `dish_rating`
  MODIFY `rating_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `eater_dish_order`
--
ALTER TABLE `eater_dish_order`
  MODIFY `orders_index` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `eater_gendish_feast`
--
ALTER TABLE `eater_gendish_feast`
  MODIFY `feast_order_index` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `feast_suggested_cooks`
--
ALTER TABLE `feast_suggested_cooks`
  MODIFY `feast_cooks_index` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `generic_dishes`
--
ALTER TABLE `generic_dishes`
  MODIFY `gendish_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ingredients`
--
ALTER TABLE `ingredients`
  MODIFY `ingredient_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_account`
--
ALTER TABLE `user_account`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cook`
--
ALTER TABLE `cook`
  ADD CONSTRAINT `cook_ibfk_1` FOREIGN KEY (`cook_id`) REFERENCES `user_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cook_cuisine_types`
--
ALTER TABLE `cook_cuisine_types`
  ADD CONSTRAINT `cook_cuisine_types_ibfk_1` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cook_delivery`
--
ALTER TABLE `cook_delivery`
  ADD CONSTRAINT `cook_delivery_ibfk_1` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `cook_delivery_ibfk_2` FOREIGN KEY (`delivery_id`) REFERENCES `delivery_service` (`delivery_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cook_donations`
--
ALTER TABLE `cook_donations`
  ADD CONSTRAINT `cook_donations_ibfk_1` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `cook_donations_ibfk_2` FOREIGN KEY (`charity_id`) REFERENCES `charity_organizations` (`charity_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cook_kitchen_pics`
--
ALTER TABLE `cook_kitchen_pics`
  ADD CONSTRAINT `cook_kitchen_pics_ibfk_1` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cook_promocodes`
--
ALTER TABLE `cook_promocodes`
  ADD CONSTRAINT `cook_promocodes_ibfk_1` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cook_review`
--
ALTER TABLE `cook_review`
  ADD CONSTRAINT `cook_review_ibfk_1` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `cook_review_ibfk_2` FOREIGN KEY (`eater_id`) REFERENCES `eater` (`eater_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `cook_review_pics`
--
ALTER TABLE `cook_review_pics`
  ADD CONSTRAINT `cook_review_pics_ibfk_1` FOREIGN KEY (`review_id`) REFERENCES `cook_review` (`review_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dishes`
--
ALTER TABLE `dishes`
  ADD CONSTRAINT `dishes_ibfk_1` FOREIGN KEY (`gendish_id`) REFERENCES `generic_dishes` (`gendish_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dishes_ibfk_2` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dish_ingredients`
--
ALTER TABLE `dish_ingredients`
  ADD CONSTRAINT `dish_ingredients_ibfk_1` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`dish_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dish_ingredients_ibfk_2` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`ingredient_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dish_rating`
--
ALTER TABLE `dish_rating`
  ADD CONSTRAINT `dish_rating_ibfk_1` FOREIGN KEY (`eater_id`) REFERENCES `eater` (`eater_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dish_rating_ibfk_2` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`dish_id`);

--
-- Constraints for table `dish_to_generic`
--
ALTER TABLE `dish_to_generic`
  ADD CONSTRAINT `dish_to_generic_ibfk_1` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`dish_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `dish_to_generic_ibfk_2` FOREIGN KEY (`gendish_id`) REFERENCES `generic_dishes` (`gendish_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `eater`
--
ALTER TABLE `eater`
  ADD CONSTRAINT `eater_ibfk_1` FOREIGN KEY (`eater_id`) REFERENCES `user_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `eater_allergens`
--
ALTER TABLE `eater_allergens`
  ADD CONSTRAINT `eater_allergens_ibfk_1` FOREIGN KEY (`eater_id`) REFERENCES `eater` (`eater_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `eater_cart`
--
ALTER TABLE `eater_cart`
  ADD CONSTRAINT `eater_cart_ibfk_1` FOREIGN KEY (`eater_id`) REFERENCES `eater` (`eater_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eater_cart_ibfk_2` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`dish_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eater_cart_ibfk_3` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `eater_dish_order`
--
ALTER TABLE `eater_dish_order`
  ADD CONSTRAINT `eater_dish_order_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order_status` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eater_dish_order_ibfk_2` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`dish_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eater_dish_order_ibfk_3` FOREIGN KEY (`eater_id`) REFERENCES `eater` (`eater_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `eater_favorite_dish`
--
ALTER TABLE `eater_favorite_dish`
  ADD CONSTRAINT `eater_favorite_dish_ibfk_1` FOREIGN KEY (`eater_id`) REFERENCES `eater` (`eater_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eater_favorite_dish_ibfk_2` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`dish_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `eater_gendish_feast`
--
ALTER TABLE `eater_gendish_feast`
  ADD CONSTRAINT `eater_gendish_feast_ibfk_1` FOREIGN KEY (`gendish_id`) REFERENCES `generic_dishes` (`gendish_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eater_gendish_feast_ibfk_2` FOREIGN KEY (`eater_id`) REFERENCES `eater` (`eater_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `eater_gendish_feast_ibfk_3` FOREIGN KEY (`order_id`) REFERENCES `order_status` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `feast_suggested_cooks`
--
ALTER TABLE `feast_suggested_cooks`
  ADD CONSTRAINT `feast_suggested_cooks_ibfk_1` FOREIGN KEY (`feast_id`) REFERENCES `eater_gendish_feast` (`feast_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `feast_suggested_cooks_ibfk_2` FOREIGN KEY (`gendish_id`) REFERENCES `generic_dishes` (`gendish_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `feast_suggested_cooks_ibfk_3` FOREIGN KEY (`cook_id`) REFERENCES `cook` (`cook_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `generic_dish_ingredients`
--
ALTER TABLE `generic_dish_ingredients`
  ADD CONSTRAINT `generic_dish_ingredients_ibfk_1` FOREIGN KEY (`gendish_id`) REFERENCES `generic_dishes` (`gendish_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `generic_dish_ingredients_ibfk_2` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`ingredient_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `order_status`
--
ALTER TABLE `order_status`
  ADD CONSTRAINT `order_status_ibfk_1` FOREIGN KEY (`delivery_id`) REFERENCES `delivery_service` (`delivery_id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

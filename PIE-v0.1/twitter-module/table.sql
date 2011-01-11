

CREATE TABLE `message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(45) DEFAULT NULL,
  `date` timestamp NULL DEFAULT NULL,
  `id_msg` varchar(45) DEFAULT NULL,
  `msg` varchar(160) DEFAULT NULL,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `s1` (`msg`)
);


CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `car_id` varchar(45) DEFAULT NULL,
  `login` varchar(45) DEFAULT NULL,
  `password` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index2` (`car_id`,`login`),
  UNIQUE KEY `user_UNIQUE` (`login`)
);
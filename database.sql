USE project;

-- This sql script will flush the database!!!
-- to update database with this script:
-- run command: mysql -u student -p
-- enter password student
-- run command: \. /usr/local/node/docs/project/database.sql

-- or ...

-- mysql --user=student --password=student < /usr/local/node/docs/project/database.sql
-- ^ this doesn't give you any feedback though...

DROP TRIGGER IF EXISTS tri_category_counter1;
DROP TRIGGER IF EXISTS tri_category_counter2;
DROP TRIGGER IF EXISTS tri_unit_ingr_counter1;
DROP TRIGGER IF EXISTS tri_unit_ingr_counter2;

DROP TABLE IF EXISTS recipe_ingredient;
DROP TABLE IF EXISTS ingredient;
DROP TABLE IF EXISTS unit;
DROP TABLE IF EXISTS recipe_comment;
DROP TABLE IF EXISTS recipe_ranking;
DROP TABLE IF EXISTS recipe_picture;
DROP TABLE IF EXISTS recipe;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS user_connections;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS wiki_content;
DROP TABLE IF EXISTS wiki;
DROP TABLE IF EXISTS wiki_category;
DROP TABLE IF EXISTS picture;
DROP TABLE IF EXISTS passkeys;
DROP TABLE IF EXISTS video;

CREATE TABLE passkeys
(
user_id VARCHAR(40) NOT NULL,
pass VARCHAR(40) NOT NULL,
salt VARCHAR(40) NOT NULL,
CONSTRAINT pk_passkeys PRIMARY KEY(user_id)
);

CREATE TABLE picture
(
picture_id SERIAL NOT NULL AUTO_INCREMENT,
name VARCHAR(40) NOT NULL,
caption VARCHAR(50),
location VARCHAR(100),
CONSTRAINT pk_picture PRIMARY KEY(picture_id)
);

CREATE TABLE video
(
video_id SERIAL NOT NULL AUTO_INCREMENT,
name VARCHAR(40) NOT NULL,
caption VARCHAR(50),
address VARCHAR(100),
CONSTRAINT pk_video PRIMARY KEY(video_id)
);

CREATE TABLE wiki
(
wiki_id SERIAL,
video_id BIGINT UNSIGNED,
wiki_cat_id BIGINT UNSIGNED,
wiki_title VARCHAR(40) NOT NULL,
CONSTRAINT pk_wiki PRIMARY KEY(wiki_id),
CONSTRAINT fk_wiki_video FOREIGN KEY(video_id) REFERENCES video(video_id)
);

CREATE TABLE wiki_category
(
wiki_cat_id SERIAL NOT NULL AUTO_INCREMENT,
category_name VARCHAR(40) NOT NULL,
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_wiki_cat PRIMARY KEY(wiki_cat_id)
);

CREATE TABLE wiki_content
(
wiki_cont_id SERIAL,
wiki_id BIGINT UNSIGNED NOT NULL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
title VARCHAR(40),
content VARCHAR(5000) NOT NULL,
CONSTRAINT pk_wiki_cont PRIMARY KEY(wiki_cont_id),
CONSTRAINT fk_wiki FOREIGN KEY(wiki_id) REFERENCES wiki(wiki_id),
CONSTRAINT fk_cont_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
);

CREATE TABLE user
(
user_id VARCHAR(40) NOT NULL UNIQUE,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
user_group VARCHAR(20) NOT NULL,
user_fname VARCHAR(40) NOT NULL,
user_lname VARCHAR(40) NOT NULL,
email VARCHAR(50) NOT NULL,
date_added DATETIME NOT NULL,
user_points INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_user PRIMARY KEY(user_id),
CONSTRAINT fk_user_passkeys FOREIGN KEY(user_id) REFERENCES passkeys(user_id),
CONSTRAINT fk_user_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
);

CREATE TABLE user_connections
(
connection_id SERIAL,
user_id_1 VARCHAR(40) NOT NULL,
user_id_2 VARCHAR(40) NOT NULL, 
relationship VARCHAR(12) NOT NULL DEFAULT 0,
accepted INT(1) NOT NULL DEFAULT 0,
active INT(1) NOT NULL DEFAULT 0,
CONSTRAINT pk_user_connections PRIMARY KEY(connection_id),
CONSTRAINT fk_user_1 FOREIGN KEY(user_id_1) REFERENCES user(user_id),
CONSTRAINT fk_user_2 FOREIGN KEY(user_id_2) REFERENCES user(user_id)
);

CREATE TABLE category
(
category_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
category_name VARCHAR(40) NOT NULL,
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_category PRIMARY KEY(category_id)
);

CREATE TABLE recipe
(
recipe_id SERIAL,
owner_id VARCHAR(40) NOT NULL,
category_id SMALLINT UNSIGNED NOT NULL,
recipe_name VARCHAR(40) NOT NULL,
public TINYINT(1) NOT NULL DEFAULT 1,
serving_size VARCHAR(10) DEFAULT '0-0',
prep_time TIME DEFAULT 0,
ready_time TIME DEFAULT 0,
directions VARCHAR(5000) NOT NULL,
date_added DATETIME NOT NULL,
date_edited DATETIME,
CONSTRAINT pk_recipe PRIMARY KEY(recipe_id),
CONSTRAINT fk_recipe_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);

CREATE TABLE recipe_picture
(
recipe_picture_id SERIAL,
recipe_id BIGINT UNSIGNED NOT NULL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
CONSTRAINT pk_recipe_picture PRIMARY KEY(recipe_picture_id),
CONSTRAINT fk_recipe_picture_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id),
CONSTRAINT fk_recipe_picture_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
);

CREATE TABLE recipe_comment
(
comment_id SERIAL,
owner_id VARCHAR(40) NOT NULL,
recipe_id BIGINT UNSIGNED NOT NULL,
reply_comment_id BIGINT UNSIGNED DEFAULT 0,
content VARCHAR(500) NOT NULL,
date_added DATETIME NOT NULL,
date_edited DATETIME,
CONSTRAINT pk_comment PRIMARY KEY(comment_id),
CONSTRAINT fk_recipe_comment_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_comment_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id)
);

CREATE TABLE recipe_ranking
(
rank_id SERIAL,
owner_id VARCHAR(40) NOT NULL,
recipe_id BIGINT UNSIGNED NOT NULL,
rank TINYINT UNSIGNED DEFAULT 0,
date_added DATETIME NOT NULL,
date_edited DATETIME,
CONSTRAINT pk_recipe_ranking PRIMARY KEY(rank_id),
CONSTRAINT fk_recipe_ranking_user FOREIGN KEY(owner_id) REFERENCES user(user_id),
CONSTRAINT fk_recipe_ranking_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id)
);

CREATE TABLE unit
(
unit_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
unit_name VARCHAR(20) NOT NULL,
abrev VARCHAR(10) DEFAULT '',
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_unit PRIMARY KEY(unit_id)
);

CREATE TABLE ingredient
(
ingr_id SERIAL,
picture_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
ingr_name VARCHAR(40) NOT NULL,
use_count INT UNSIGNED NOT NULL DEFAULT 0,
CONSTRAINT pk_ingredient PRIMARY KEY(ingr_id),
CONSTRAINT fk_ingredient_picture FOREIGN KEY(picture_id) REFERENCES picture(picture_id)
);

CREATE TABLE recipe_ingredient
(
recipe_ingr_id SERIAL,
recipe_id BIGINT UNSIGNED NOT NULL,
ingr_id BIGINT UNSIGNED NOT NULL,
unit_id SMALLINT UNSIGNED NOT NULL,
unit_amount DOUBLE(7,4) NOT NULL,
CONSTRAINT fk_rec_ingr_recipe FOREIGN KEY(recipe_id) REFERENCES recipe(recipe_id),
CONSTRAINT fk_rec_ingr_ingr FOREIGN KEY(ingr_id) REFERENCES ingredient(ingr_id),
CONSTRAINT fk_rec_ingr_unit FOREIGN KEY(unit_id) REFERENCES unit(unit_id),
CONSTRAINT pk_rec_ingr PRIMARY KEY(recipe_ingr_id)
);

-- Triggers

delimiter |

CREATE TRIGGER tri_category_counter1 AFTER INSERT ON recipe
	FOR EACH ROW BEGIN
		UPDATE category SET use_count = use_count + 1 WHERE category_id = NEW.category_id;
	END;
|

CREATE TRIGGER tri_category_counter2 AFTER DELETE ON recipe
	FOR EACH ROW BEGIN
		UPDATE category SET use_count = use_count - 1 WHERE category_id = OLD.category_id;
	END;
|

CREATE TRIGGER tri_unit_ingr_counter1 AFTER INSERT ON recipe_ingredient
	FOR EACH ROW BEGIN
		UPDATE unit SET use_count = use_count + 1 WHERE unit_id = NEW.unit_id;
		UPDATE ingredient SET use_count = use_count + 1 WHERE ingr_id = NEW.ingr_id;
	END;
|

CREATE TRIGGER tri_unit_ingr_counter2 AFTER DELETE ON recipe_ingredient
	FOR EACH ROW BEGIN
		UPDATE unit SET use_count = use_count - 1 WHERE unit_id = OLD.unit_id;
		UPDATE ingredient SET use_count = use_count - 1 WHERE ingr_id = OLD.ingr_id;
	END;
|

delimiter ;

INSERT INTO passkeys (user_id, pass, salt) VALUES('Sam', 'e233560939c66735c503f136f32a431cb203db78', 'aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Mike', '4d00564fd19d74efff6ba1f392f757f33fca273b', '4196ce6a9377e11ecc9f01517e8a118c4b596646');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Julia', '9bb9949ea212c05242d0110858987af879c84041', '5fc0d6f9d1b18a1a28738a9834ef6bf12c2716f9');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Curtis', '041b2e52b42326af4c9ac9c63504dd623ab51895', '1019078d1d90533aed697b1e94fbdba9bf3f4d4a');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Mona', 'eb99762e96c220d67e6683c25fcd3666ea67041b', 'aecbe931addcaba9bf8eaeaa92606fc6d1b35857');
INSERT INTO passkeys (user_id, pass, salt) VALUES('James', '047281f78707c60625a3c16b5c23daa664e0b09d', '81bb94396ea3e8ff99b9fc3d9ffcd0510d979e0c');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Catherine', 'e540334e5f07b9b136c5b0b489df7a2efa736947', '73e8a8b5c53e648b2ce978a499edba4e64482d99');
INSERT INTO passkeys (user_id, pass, salt) VALUES('John', '2eb605c2fcd4b05b709bef4cad5ecd289139a143', 'a8f474ca1460e5670c1f0756b99f4d9a01ffbab9');
INSERT INTO passkeys (user_id, pass, salt) VALUES('Felicia', 'bcf3f218b57a5362e3162b77d1dfb54167923618', 'c031c0deb66133614c85bdc40a8019ec90c01b98');

INSERT INTO picture (name, caption, location) VALUES('unknown', 'No Picture', 'unknown.png'); -- 1
INSERT INTO picture (name, caption, location) VALUES('sam1', 'Sam Luebbert', 'sam1.png'); -- 2
INSERT INTO picture (name, caption, location) VALUES('Potato Salad', 'Potato Salad Yum!', 'pre_1.jpg'); -- 3
INSERT INTO picture (name, caption, location) VALUES('Grandmas Pumpkin Pie', 'Pumpkin Pie! - It has pumpkin in it.', 'pre_2.jpg'); -- 4
INSERT INTO picture (name, caption, location) VALUES('Raspberry Cheesecake Bars', 'Raspberry Cheesecake Bars; They are good for you!', 'pre_3.jpg'); -- 5
INSERT INTO picture (name, caption, location) VALUES('curtis', 'Curtis Sydnor', 'curtis_sydnor.jpg'); -- 6
INSERT INTO picture (name, caption, location) VALUES('mona', 'Mona Lisa', 'mona_lisa.jpg'); -- 7
INSERT INTO picture (name, caption, location) VALUES('james', 'James "Sawyer" Ford', 'james_ford.jpg'); -- 8
INSERT INTO picture (name, caption, location) VALUES('kate', 'Kate Middleton', 'kate_middleton.jpg'); -- 9
INSERT INTO picture (name, caption, location) VALUES('john', 'Johnny Depp', 'johnny_depp.jpg'); -- 10
INSERT INTO picture (name, caption, location) VALUES('felicia', 'Falicia Day', 'felicia_day.jpg'); -- 11
INSERT INTO picture (name, caption, location) VALUES('Grandmas Pumpkin Pie', 'Just out of the oven.', 'pre_2_2.jpg'); -- 12

INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added) VALUES('Sam', 2, 'admin', 'Sam', 'Luebbert', 'sgluebbert1@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added) VALUES('Mike', 'admin', 'Mike', 'Little', 'malittle3@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, user_group, user_fname, user_lname, email, date_added) VALUES('Julia', 'admin', 'Julia', 'Collins', 'jlcollins4@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added) VALUES('Curtis', 6, 'admin', 'Curtis', 'Sydnor', 'casydnor1@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added) VALUES('Mona', 7, 'admin', 'Mona', 'Lisa', 'mglisa@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added) VALUES('James', 8, 'admin', 'James', 'Ford', 'jsford@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added) VALUES('Catherine', 9, 'admin', 'Catherine', 'Middleton', 'cemiddleton@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added) VALUES('John', 10, 'admin', 'John', 'Depp', 'jcdepp@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));
INSERT INTO user (user_id, picture_id, user_group, user_fname, user_lname, email, date_added) VALUES('Felicia', 11, 'admin', 'Felicia', 'Day', 'fkday@cougars.ccis.edu', STR_TO_DATE('9,14,2012 15:00', '%m,%d,%Y %H:%i'));

INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Sam', 'Julia', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Sam', 'Curtis', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Sam', 'Felicia', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Sam', 'John', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, active) VALUES('Sam', 'James', 'Follow', 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Sam', 'Catherine', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, active) VALUES('Sam', 'John', 'Follow', 0);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Julia', 'Mike', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Julia', 'Curtis', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, active) VALUES('Julia', 'Catherine', 'Follow', 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Mike', 'Curtis', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Mike', 'Felicia', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Curtis', 'Felicia', 'Friend', 1, 1);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, accepted, active) VALUES('Curtis', 'John', 'Friend', 0, 0);
INSERT INTO user_connections (user_id_1, user_id_2, relationship, active) VALUES('Curtis', 'Mona', 'Follow', 1);

INSERT INTO unit (unit_name) VALUES(''); -- used for no unit ex: "4 eggs" 1
INSERT INTO unit (unit_name, abrev) VALUES('Teaspoon', 'tsp');  -- 2
INSERT INTO unit (unit_name, abrev) VALUES('Tablespoon', 'tbsp'); -- 3
INSERT INTO unit (unit_name, abrev) VALUES('Dessertspoon', 'dstspn');  -- 4
INSERT INTO unit (unit_name) VALUES('Cup'); -- 5
INSERT INTO unit (unit_name) VALUES('Drop');  -- 6
INSERT INTO unit (unit_name, abrev) VALUES('Pinch', 'pn');  -- 7
INSERT INTO unit (unit_name) VALUES('Dash');  -- 8
INSERT INTO unit (unit_name) VALUES('Smidgen');  -- 9
INSERT INTO unit (unit_name) VALUES('Handfull');  -- 10
INSERT INTO unit (unit_name, abrev) VALUES('Gill', 'gi');  -- 11
INSERT INTO unit (unit_name, abrev) VALUES('Ounce', 'oz');  -- 12
INSERT INTO unit (unit_name, abrev) VALUES('Fluid Ounces', 'fl oz');  -- 13
INSERT INTO unit (unit_name, abrev) VALUES('Pound', 'lb');  -- 14
INSERT INTO unit (unit_name, abrev) VALUES('Pint', 'pt');  -- 15
INSERT INTO unit (unit_name, abrev) VALUES('Quart', 'qt');  -- 16
INSERT INTO unit (unit_name, abrev) VALUES('Gallon', 'gal');  -- 17
INSERT INTO unit (unit_name) VALUES('Jigger');  -- 18
INSERT INTO unit (unit_name, abrev) VALUES('Peck', 'pk');  -- 19
INSERT INTO unit (unit_name, abrev) VALUES('Bushel', 'bu'); -- 20
INSERT INTO unit (unit_name) VALUES('Firkin');  -- 21
INSERT INTO unit (unit_name) VALUES('Hogshead');  -- 22
INSERT INTO unit (unit_name, abrev) VALUES('Mililiter', 'ml');  -- 23
INSERT INTO unit (unit_name, abrev) VALUES('Cubic Centimeter', 'cc');  -- 24
INSERT INTO unit (unit_name) VALUES('Cubic Foot');  -- 25
INSERT INTO unit (unit_name) VALUES('Cubic Inch');  -- 26
INSERT INTO unit (unit_name, abrev) VALUES('Liter', 'l');  --  27
INSERT INTO unit (unit_name) VALUES('Fifth');  -- 28
INSERT INTO unit (unit_name) VALUES('Shot');  -- 29
INSERT INTO unit (unit_name, abrev) VALUES('Gram', 'g');  -- 30
INSERT INTO unit (unit_name, abrev) VALUES('Kilogram', 'kg');  -- 31
INSERT INTO unit (unit_name, abrev) VALUES('Inch', 'in');  --  32
INSERT INTO unit (unit_name, abrev) VALUES('Truckload', 'tl');  -- 33
INSERT INTO unit (unit_name, abrev) VALUES('Partial Truckload', 'ltl');  -- 34
INSERT INTO unit (unit_name) VALUES('Crate');  -- 35
INSERT INTO unit (unit_name) VALUES('Bucket');  -- 36

INSERT INTO category (category_name) VALUES(''); -- 1
INSERT INTO category (category_name) VALUES('Side Dishes'); -- 2
INSERT INTO category (category_name) VALUES('Fall Desserts'); -- 3
INSERT INTO category (category_name) VALUES('Cake'); -- 4
INSERT INTO category (category_name) VALUES('Pie'); -- 5
INSERT INTO category (category_name) VALUES('Beef'); -- 6
INSERT INTO category (category_name) VALUES('Chicken'); -- 7
INSERT INTO category (category_name) VALUES('Pork'); -- 8
INSERT INTO category (category_name) VALUES('Breakfast'); -- 9
INSERT INTO category (category_name) VALUES('Desserts'); -- 10

INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Curtis', 2, 'Potato Salad', '4-6', STR_TO_DATE('00:30', '%H:%i'), STR_TO_DATE('00:35', '%H:%i'), 'directions', STR_TO_DATE('9,29,2012 19:00', '%m,%d,%Y %H:%i'));  -- 1
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Sam', 3, 'Grandmas Pumpkin Pie', '5-6', STR_TO_DATE('01:10', '%H:%i'), STR_TO_DATE('02:00', '%H:%i'), 'directions', STR_TO_DATE('9,30,2012 11:00', '%m,%d,%Y %H:%i'));  -- 2
INSERT INTO recipe (owner_id, category_id, recipe_name, serving_size, prep_time, ready_time, directions, date_added) VALUES('Julia', 10, 'Raspberry Cheesecake Bars', '3-5', STR_TO_DATE('00:40', '%H:%i'), STR_TO_DATE('01:10', '%H:%i'), 'directions', STR_TO_DATE('9,28,2012 12:00', '%m,%d,%Y %H:%i')); -- 3

INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(1, 3);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(2, 4);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(2, 12);
INSERT INTO recipe_picture (recipe_id, picture_id) VALUES(3, 5);

INSERT INTO recipe_comment (owner_id, recipe_id, content, date_added) VALUES('Curtis', 2, "Hey, this recipe seems good!", STR_TO_DATE('10,1,2012 16:34:21', '%m,%d,%Y %H:%i:%s')); -- 1
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Sam', 2, 1, "Thanks! Try it out sometime soon.", STR_TO_DATE('10,1,2012 19:04:54', '%m,%d,%Y %H:%i:%s')); -- 2
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Julia', 2, 2, "I bet it is not that good.", STR_TO_DATE('10,1,2012 19:43:24', '%m,%d,%Y %H:%i:%s')); -- 3
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Mike', 2, 3, "Ha!", STR_TO_DATE('10,1,2012 19:44:05', '%m,%d,%Y %H:%i:%s')); -- 4
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Sam', 2, 3, "Oh thaaanks.", STR_TO_DATE('10,1,2012 20:45:35', '%m,%d,%Y %H:%i:%s')); -- 4
INSERT INTO recipe_comment (owner_id, recipe_id, reply_comment_id, content, date_added) VALUES('Curtis', 2, 2, "Ok, I will", STR_TO_DATE('10,1,2012 19:47:45', '%m,%d,%Y %H:%i:%s')); -- 5

INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Sam', 1, 6, STR_TO_DATE('9,28,2012 13:49:04', '%m,%d,%Y %H:%i:%s')); -- 1
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Julia', 1, 3, STR_TO_DATE('9,28,2012 17:43:34', '%m,%d,%Y %H:%i:%s')); -- 2
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Mike', 2, 10, STR_TO_DATE('9,30,2012 11:42:14', '%m,%d,%Y %H:%i:%s')); -- 3
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Julia', 2, 5, STR_TO_DATE('9,30,2012 15:23:45', '%m,%d,%Y %H:%i:%s')); -- 4
INSERT INTO recipe_ranking (owner_id, recipe_id, rank, date_added) VALUES('Sam', 3, 10, STR_TO_DATE('10,2,2012 19:34:02', '%m,%d,%Y %H:%i:%s')); -- 4

INSERT INTO ingredient (ingr_name) VALUES('Potatoes'); --  1
INSERT INTO ingredient (ingr_name) VALUES('Italian Salad Dressing');  -- 2
INSERT INTO ingredient (ingr_name) VALUES('Mayonnaise');  -- 3
INSERT INTO ingredient (ingr_name) VALUES('Chopped Green Onions');  -- 4
INSERT INTO ingredient (ingr_name) VALUES('Chopped Fresh Dill');  -- 5
INSERT INTO ingredient (ingr_name) VALUES('Dijon Mustard');  -- 6
INSERT INTO ingredient (ingr_name) VALUES('Lemon Juice');  -- 7
INSERT INTO ingredient (ingr_name) VALUES('Pepper');  -- 8
INSERT INTO ingredient (ingr_name) VALUES('Unbaked Pie Shells');  -- 9
INSERT INTO ingredient (ingr_name) VALUES('Sugar');  -- 10
INSERT INTO ingredient (ingr_name) VALUES('Salt');  -- 11
INSERT INTO ingredient (ingr_name) VALUES('Cinnamon');  -- 12
INSERT INTO ingredient (ingr_name) VALUES('Ginger');  -- 13
INSERT INTO ingredient (ingr_name) VALUES('Nutmeg');  -- 14
INSERT INTO ingredient (ingr_name) VALUES('Eggs');  -- 15
INSERT INTO ingredient (ingr_name) VALUES('Solid Pack Pumpkin');  -- 16
INSERT INTO ingredient (ingr_name) VALUES('Evaporated Milk');  -- 17
INSERT INTO ingredient (ingr_name) VALUES('All Purpose Flour');  -- 18
INSERT INTO ingredient (ingr_name) VALUES('Brown Sugar');  -- 19
INSERT INTO ingredient (ingr_name) VALUES('Finely Chopped Sliced Almonds');  -- 20
INSERT INTO ingredient (ingr_name) VALUES('Butter Flavored Shortening');  -- 21
INSERT INTO ingredient (ingr_name) VALUES('Softened Cream Cheese');  -- 22
INSERT INTO ingredient (ingr_name) VALUES('Granulated Sugar');  -- 23
INSERT INTO ingredient (ingr_name) VALUES('Almond Extract');  -- 24
INSERT INTO ingredient (ingr_name) VALUES('Seedless Raspberry Preserves');  -- 25
INSERT INTO ingredient (ingr_name) VALUES('Flaked Coconut');  -- 26
INSERT INTO ingredient (ingr_name) VALUES('Sliced Almonds');  -- 27

INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 1, 1, 3); -- Potato Salad, 3 pounds potatoes scrubbed and quartered
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 2, 5, .5); -- Potato Salad, Italian Style Dressing 3/4 cup
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 3, 5, .75); -- Potato Salad, 3/4 cup mayonnaise
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 4, 5, .25); -- Potato Salad, 1/4 chopped green onions
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 5, 2, 2); -- Potato Salad, 2 teaspoons chopped fresh dill
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 6, 2, 1); -- Potato Salad, 1 teaspoon digjon mustard (optional)
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 7, 2, 1); -- Potato Salad, 1 teaspoon lemon juice
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(1, 8, 2, .125); -- Potato Salad, 1/8 teaspoon pepper
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 9, 1, 2); -- Grandmas Pumpkin Pie, 2 (9inch) unbaked pie shells
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 10, 5, 1.5); -- Grandmas Pumpkin Pie, 1 1/2 cups sugar
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 11, 2, 1); -- Grandmas Pumpkin Pie, 1 teaspoon salt
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 12, 2, 1); -- Grandmas Pumpkin Pie, 1 teaspoon cinnamon
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 13, 2, .5); -- Grandmas Pumpkin Pie, 1/2 teaspoon ginger
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 14, 2, .5); -- Grandmas Pumpkin Pie, 1/2 teaspoon nutmeg
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 15, 1, 4); -- Grandmas Pumpkin Pie, 4 eggs
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 16, 1, 3.5); -- Grandmas Pumpkin Pie, 3 1/2 solid pack pumpkin
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(2, 17, 5, 1.5); -- Grandmas Pumpkin Pie, 1 1/2 cups evaporated milk
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 18, 5, 1.25); -- Respberry Cheesecake Bars, 1 1/4 cup all purpose flour
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 19, 5, .5); -- Respberry Cheesecake Bars, 1/2 cup packed brown sugar
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 20, 5, .5); -- Respberry Cheesecake Bars, 1/2 cup finly chopped sliced almonds
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 21, 5, 1.5); -- Respberry Cheesecake Bars, Butter Flavored Shortening
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 22, 12, 16); -- Respberry Cheesecake Bars, 2 8-ounce packagesCream Cheese, Softended
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 23, 5, 2/3); -- Respberry Cheesecake Bars, 2/3 cup Granulated Sugar
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 15, 1, 2); -- Respberry Cheesecake Bars, 2 eggs
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 24, 2, .75); -- Respberry Cheesecake Bars, 3/4 teaspoon almond extract
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 25, 5, 1); -- Respberry Cheesecake Bars, 1 cup seedless raspberry preserves or other  preserves or jam
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 26, 5, .5); -- Respberry Cheesecake Bars, 1/2 cup flaked coconut
INSERT INTO recipe_ingredient (recipe_id, ingr_id, unit_id, unit_amount) VALUES(3, 27, 5, .5); -- Respberry Cheesecake Bars, 1/2 cup sliced almonds

-- Wiki data
INSERT INTO video (video_id, name, caption, address) VALUES(1, "Test Video", "Test Caption", "http://www.youtube.com/embed/ghb6eDopW8I"); -- test video

-- Wiki categories
INSERT INTO wiki_category (category_name) VALUES ("Ingredients");

-- Wiki pages
INSERT INTO wiki (wiki_id, video_id, wiki_title, wiki_cat_id) VALUES(1, 1, "Common Ingredients",1);  -- test wiki page

-- Wiki content
INSERT INTO wiki_content (wiki_cont_id, wiki_id, picture_id, title, content) VALUES(1,1,1, "Salt", "salt");  -- test wiki content
INSERT INTO wiki_content (wiki_cont_id, wiki_id, picture_id, title, content) VALUES(2,1,1, "Sugar", "sugar");

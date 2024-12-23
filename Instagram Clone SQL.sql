use ig_clone;

select * from comments;

select * from follows;

select * from likes;

select * from photo_tags;

select * from tags;

select * from users;

-- Find the 10 oldest users

select * from users
order by created_at
limit 10;

-- What day of the week do most users register on?

select dayname(created_at) as DayName
from users
order by dayname(created_at) desc
limit 1;

-- Find out the users who havent posted a picture.

select username from users
left join photos on users.id=photos.user_id
where photos.id is null;

-- Write a query to find out who has got the most number of likes on a single photo.

SELECT 
    username,
    photos.id,
    photos.image_url, 
    COUNT(*) AS total
FROM photos
INNER JOIN likes
    ON likes.photo_id = photos.id
INNER JOIN users
    ON photos.user_id = users.id
GROUP BY photos.id
ORDER BY total DESC
LIMIT 1;

-- How many times does an average user post?

select round((select count(*) from photos)/(select count(*) from users),3) as "Average no. of times a user posts";

-- User ranking by postings( higher to lower)

SELECT users.username,COUNT(photos.image_url)
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY 2 DESC;

-- Total posts by users

SELECT SUM(user_posts.total_posts_per_user) as "Total Posts"
FROM (SELECT users.username,COUNT(photos.image_url) AS total_posts_per_user
		FROM users
		JOIN photos ON users.id = photos.user_id
		GROUP BY users.id) AS user_posts;
        
-- Total number of users who have posted at least one time.alter

SELECT COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM users
JOIN photos ON users.id = photos.user_id;

-- What are the top 5 used hashtags?

SELECT tag_name, COUNT(tag_name) AS total
FROM tags
JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC
limit 5;

-- Find users who have liked every single photo on the site.

SELECT users.id,username, COUNT(users.id) As total_likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING total_likes_by_user = (SELECT COUNT(*) FROM photos);

-- Find the photos uploaded by a specific user with username = 'john_doe'

SELECT photos.* 
FROM photos
JOIN users ON photos.user_id = users.id
WHERE users.username = 'john_doe';

-- Write a query to display all comments on a photo with id = 10.

SELECT comments.* 
FROM comments
WHERE photo_id = 10;

-- List the top 5 users with the most uploaded photos. 

SELECT users.username, COUNT(photos.id) AS photo_count
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY photo_count DESC
LIMIT 5;

-- Write a query to find the number of followers for each user.

SELECT followee_id AS user_id, COUNT(follower_id) AS follower_count
FROM follows
GROUP BY followee_id;


-- Find users who liked a specific photo with id = 15.

SELECT users.username
FROM users
JOIN likes ON users.id = likes.user_id
WHERE likes.photo_id = 15;

-- List all photos along with their like counts.

SELECT photos.id AS photo_id, COUNT(likes.user_id) AS like_count
FROM photos
LEFT JOIN likes ON photos.id = likes.photo_id
GROUP BY photos.id;

-- Write a query to find photos that have received no likes.

SELECT photos.* 
FROM photos
LEFT JOIN likes ON photos.id = likes.photo_id
WHERE likes.photo_id IS NULL;

--  Display the total number of comments on each photo.

SELECT photo_id, COUNT(id) AS comment_count
FROM comments
GROUP BY photo_id;

-- List the top 3 most followed users along with their follower count.

SELECT followee_id AS user_id, COUNT(follower_id) AS follower_count
FROM follows
GROUP BY followee_id
ORDER BY follower_count DESC
LIMIT 3;

-- Identify users who follow each other.

SELECT u1.username AS user1, u2.username AS user2
FROM follows AS f1
JOIN follows AS f2 ON f1.follower_id = f2.followee_id AND f1.followee_id = f2.follower_id
JOIN users AS u1 ON f1.follower_id = u1.id
JOIN users AS u2 ON f1.followee_id = u2.id;

-- Find the photo with the highest number of comments. 

SELECT photo_id, COUNT(id) AS comment_count
FROM comments
GROUP BY photo_id
ORDER BY comment_count DESC
LIMIT 1;

-- Write a query to find the average number of likes per photo.

SELECT AVG(like_count) AS avg_likes_per_photo
FROM (
    SELECT photos.id AS photo_id, COUNT(likes.user_id) AS like_count
    FROM photos
    LEFT JOIN likes ON photos.id = likes.photo_id
    GROUP BY photos.id
) AS photo_likes;

--  Identify the users who have the highest number of mutual followers (users following each other).

SELECT u1.username AS user1, u2.username AS user2, COUNT(*) AS mutual_follow_count
FROM follows AS f1
JOIN follows AS f2 
    ON f1.follower_id = f2.followee_id AND f1.followee_id = f2.follower_id
JOIN users AS u1 ON f1.follower_id = u1.id
JOIN users AS u2 ON f1.followee_id = u2.id
GROUP BY u1.username, u2.username
ORDER BY mutual_follow_count DESC;


-- Retrieve all photos with at least 3 likes and at least 2 comments.

SELECT p.id AS photo_id, COUNT(DISTINCT l.user_id) AS like_count, COUNT(DISTINCT c.id) AS comment_count
FROM photos AS p
LEFT JOIN likes AS l ON p.id = l.photo_id
LEFT JOIN comments AS c ON p.id = c.photo_id
GROUP BY p.id
HAVING COUNT(DISTINCT l.user_id) >= 3 AND COUNT(DISTINCT c.id) >= 2;

-- Find users who have never liked their own photos.

SELECT u.username
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1 
    FROM likes AS l
    JOIN photos AS p ON l.photo_id = p.id
    WHERE p.user_id = u.id AND l.user_id = u.id
);

-- Identify users who have commented on every photo they liked.

SELECT u.username
FROM users AS u
WHERE NOT EXISTS (
    SELECT l.photo_id
    FROM likes AS l
    WHERE l.user_id = u.id AND
          NOT EXISTS (
              SELECT 1
              FROM comments AS c
              WHERE c.photo_id = l.photo_id AND c.user_id = u.id
          )
);

-- Find photos that have more likes than the average number of likes across all photos.

SELECT p.id AS photo_id, COUNT(l.user_id) AS like_count
FROM photos AS p
LEFT JOIN likes AS l ON p.id = l.photo_id
GROUP BY p.id
HAVING COUNT(l.user_id) > (
    SELECT AVG(like_count) 
    FROM (
        SELECT COUNT(l.user_id) AS like_count
        FROM photos AS p
        LEFT JOIN likes AS l ON p.id = l.photo_id
        GROUP BY p.id
    ) AS subquery
);

-- List users who follow at least 90% of all other users.

SELECT u.username
FROM users AS u
WHERE (
    SELECT COUNT(*)
    FROM follows AS f
    WHERE f.follower_id = u.id
) >= (
    SELECT 0.9 * (COUNT(*) - 1)
    FROM users
);

-- Retrieve the top 5 most active users based on their combined activity (uploads, likes, comments).

SELECT u.username, 
       (COALESCE(photo_count, 0) + COALESCE(like_count, 0) + COALESCE(comment_count, 0)) AS total_activity
FROM users AS u
LEFT JOIN (
    SELECT user_id, COUNT(*) AS photo_count
    FROM photos
    GROUP BY user_id
) AS p ON u.id = p.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS like_count
    FROM likes
    GROUP BY user_id
) AS l ON u.id = l.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS comment_count
    FROM comments
    GROUP BY user_id
) AS c ON u.id = c.user_id
ORDER BY total_activity DESC
LIMIT 5;

-- Identify photos where the uploader has liked every comment made on their photo.

SELECT p.id AS photo_id
FROM photos AS p
WHERE NOT EXISTS (
    SELECT c.id
    FROM comments AS c
    WHERE c.photo_id = p.id AND
          NOT EXISTS (
              SELECT 1
              FROM likes AS l
              WHERE l.photo_id = c.photo_id AND l.user_id = c.user_id
          )
);

 
-- List all users who have received no likes on their photos but have liked other photos.

SELECT u.username
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1
    FROM likes AS l
    JOIN photos AS p ON l.photo_id = p.id
    WHERE p.user_id = u.id
)
AND EXISTS (
    SELECT 1
    FROM likes AS l
    WHERE l.user_id = u.id
);























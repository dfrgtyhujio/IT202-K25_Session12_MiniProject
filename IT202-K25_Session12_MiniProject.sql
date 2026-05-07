create database db_ss12;
use db_ss12;

create table users (
    user_id int primary key auto_increment,
    username varchar(50) unique not null,
    password varchar(255) not null,
    email varchar(100) unique not null,
    created_at datetime default current_timestamp
);

create table posts (
    post_id int primary key auto_increment,
    user_id int,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references users(user_id)
);

create table comments (
    comment_id int primary key auto_increment,
    post_id int,
    user_id int,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (post_id) references posts(post_id) on delete cascade,
    foreign key (user_id) references users(user_id) on delete cascade
);

create table friends (
    user_id int,
    friend_id int,
    status varchar(20) check (status in ('pending', 'accepted')),
    primary key (user_id, friend_id),
	check (user_id != friend_id),
    foreign key (user_id) references users(user_id) on delete cascade,
    foreign key (friend_id) references users(user_id) on delete cascade
);

create table likes (
    user_id int,
    post_id int,
    primary key (user_id, post_id),
    foreign key (user_id) references users(user_id) on delete cascade,
    foreign key (post_id) references posts(post_id) on delete cascade
);

insert into users (username, password, email) values 
('nguyenvana', 'pass123', 'vana@gmail.com'),
('lethib', 'pass456', 'thib@gmail.com'),
('tranvanc', 'pass789', 'vanc@gmail.com');

insert into posts (user_id, content) values 
(1, 'xin chào thế giới!'),
(1, 'đang học sql cơ bản.'),
(2, 'hôm nay thời tiết thật đẹp.');

insert into friends (user_id, friend_id, status) values 
(1, 2, 'accepted'),
(2, 3, 'pending');

insert into comments (post_id, user_id, content) values 
(1, 2, 'chào bạn nhé!'),
(3, 1, 'đúng vậy, trời rất xanh.');

insert into likes (user_id, post_id) values 
(1, 3),
(2, 1),
(3, 1);


-- Chức năng 1
create view view_user_info as
select user_id, username, email, created_at
from users;

select * from view_user_info;


-- Chức năng 2
create view view_post_statistics as
select 
	p.post_id,
    count(l.user_id) as likes,
    count(c.comment_id) as comments
from posts as p
left join likes as l on p.post_id = l.post_id
left join comments as c on p.post_id = c.post_id
group by p.post_id;

select * from view_post_statistics;


-- Chức năng 3
delimiter //
create procedure sp_add_user(
	in p_user varchar(50), 
	in p_pass varchar(255), 
	in p_mail varchar(100)
)
begin
    insert into users (username, password, email) 
    select p_user, p_pass, p_mail
    where not exists (select 1 from users where email = p_mail);
end //
delimiter ;

call sp_add_user('testuser', 'pass123', 'test@gmail.com');

select * from users where email = 'test@gmail.com';

-- Chức năng 4
delimiter //
create procedure sp_create_post(
	in p_uid int, 
	in p_txt text, 
	out p_pid int
)
begin
    insert into posts (user_id, content) values 
		(p_uid, p_txt);
    set p_pid = last_insert_id();
end //
delimiter ;

call sp_create_post(1, 'bài viết kiểm tra thủ tục', @id);

select @id;


-- Chức năng 5
delimiter //
create procedure sp_get_friends(
	in p_uid int, 
	in p_lim int, 
	in p_off int
)
begin
    select friend_id from friends 
    where user_id = p_uid and status = 'accepted'
    limit p_lim offset p_off;
end //
delimiter ;

call sp_get_friends(1, 2, 0);

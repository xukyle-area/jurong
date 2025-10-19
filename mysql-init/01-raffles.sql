CREATE DATABASE IF NOT EXISTS raffles;
USE raffles;

-- 规则表
create table rule
(
    `id`          int auto_increment comment '自增id'
        primary key,
    category_id int           null comment 'category id',
    code        varchar(64)   null comment '任务代号',
    sql_template_id  int null comment '任务的sql模版code',
    params      varchar(2048) null comment '参数',
    params_desc varchar(2048) null comment '参数描述',
    `version`   int           null comment '版本',
    `status`      int           null comment '状态:0下线,1上线',
    create_time datetime      null comment '创建时间',
    update_time datetime      null comment '更新时间'
);


-- SQL 模版表
create table sql_template
(
    id          int auto_increment comment '自增id'
        primary key,
    expression  varchar(4096)             null comment 'sql 模版',
    `desc`      varchar(32)               null comment '描述',
    create_time datetime                  null comment '创建时间',
    update_time datetime                  null comment '更新时间'
);


-- Flink 表 DDL 表
create table compliance_flink_table_ddl
(
    id         bigint auto_increment comment '序号'
        primary key,
    table_name varchar(64)   not null comment '表名',
    `desc`     varchar(32)   null comment '描述',
    ddl_sql       varchar(2048) null comment '构建语句',
    params     varchar(1024) null comment '参数',
    created_at datetime      null comment '创建时间',
    updated_at datetime      null comment '更新时间'
)
    comment '建表语句';
-- 显示创建的表
SHOW TABLES;
-- 示例：创建一个新的项目管理数据库
CREATE DATABASE IF NOT EXISTS project_management;
USE project_management;

-- 项目表
CREATE TABLE projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status ENUM('planning', 'active', 'completed', 'cancelled') DEFAULT 'planning',
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 任务表
CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status ENUM('todo', 'in_progress', 'completed') DEFAULT 'todo',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    assigned_to VARCHAR(50),
    due_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- 插入示例数据
INSERT INTO projects (name, description, status, start_date) VALUES
('网站重构', '重构公司官网，提升用户体验', 'active', '2024-01-01'),
('移动应用开发', '开发公司移动端应用', 'planning', '2024-02-01'),
('数据分析平台', '构建内部数据分析平台', 'active', '2024-01-15');

INSERT INTO tasks (project_id, title, description, status, priority, assigned_to, due_date) VALUES
(1, '需求分析', '分析用户需求和业务流程', 'completed', 'high', 'Alice', '2024-01-10 17:00:00'),
(1, '界面设计', '设计新的用户界面', 'in_progress', 'high', 'Bob', '2024-01-20 17:00:00'),
(1, '前端开发', '实现前端页面', 'todo', 'medium', 'Charlie', '2024-02-01 17:00:00'),
(2, '技术选型', '选择合适的技术栈', 'todo', 'high', 'David', '2024-02-05 17:00:00'),
(3, '数据库设计', '设计数据仓库架构', 'in_progress', 'high', 'Eve', '2024-01-25 17:00:00');

-- 创建索引
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);

-- 创建视图：项目任务概览
CREATE VIEW project_task_summary AS
SELECT 
    p.id as project_id,
    p.name as project_name,
    p.status as project_status,
    COUNT(t.id) as total_tasks,
    SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
    SUM(CASE WHEN t.status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_tasks,
    SUM(CASE WHEN t.status = 'todo' THEN 1 ELSE 0 END) as todo_tasks
FROM projects p
LEFT JOIN tasks t ON p.id = t.project_id
GROUP BY p.id, p.name, p.status;

-- 显示创建结果
SELECT '项目管理数据库创建完成!' as message;
SELECT * FROM project_task_summary;
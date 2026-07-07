/* Database Schema */

CREATE TABLE IF NOT EXISTS tasks (
	task_id INTEGER PRIMARY KEY AUTOINCREMENT,
	task_text TEXT NOT NULL,
	task_status INTEGER NOT NULL DEFAULT 0,
	task_created_at DATETIME DEFAULT datetime('now', 'localtime'),
	task_completed_at DATETIME DEFAULT datetime('now', 'localtime'),
	task_due_date DATETIME DEFAULT date('now', 'localtime')
);

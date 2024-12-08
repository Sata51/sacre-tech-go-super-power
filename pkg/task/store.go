package task

// TaskStore gère le stockage des tâches
type TaskStore struct {
	Tasks map[string]Task
}

func NewTaskStore() *TaskStore {
	return &TaskStore{
		Tasks: make(map[string]Task),
	}
}

export interface Task {
  Id: number;
  Title: string;
  Description: string;
  IsCompleted: boolean;
  CreatedAt: string;
  UpdatedAt?: string;
}

export interface CreateTaskRequest {
  title: string;
  description: string;
}

export interface UpdateTaskRequest {
  title: string;
  description: string;
  isCompleted: boolean;
}

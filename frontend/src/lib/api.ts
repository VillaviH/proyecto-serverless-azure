import axios from 'axios';
import { Task, CreateTaskRequest, UpdateTaskRequest } from '@/types/task';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:7071/api';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const taskApi = {
  // Obtener todas las tareas
  getTasks: async (): Promise<Task[]> => {
    const response = await api.get('/tasks');
    return response.data;
  },

  // Obtener una tarea por ID
  getTask: async (id: number): Promise<Task> => {
    const response = await api.get(`/tasks/${id}`);
    return response.data;
  },

  // Crear una nueva tarea
  createTask: async (task: CreateTaskRequest): Promise<Task> => {
    const response = await api.post('/tasks', task);
    return response.data;
  },

  // Actualizar una tarea
  updateTask: async (id: number, task: UpdateTaskRequest): Promise<Task> => {
    const response = await api.put(`/tasks/${id}`, task);
    return response.data;
  },

  // Eliminar una tarea
  deleteTask: async (id: number): Promise<void> => {
    await api.delete(`/tasks/${id}`);
  },
};

export default api;
// Force rebuild jueves,  3 de julio de 2025, 18:38:35 -05
// Force rebuild jueves,  3 de julio de 2025, 18:41:30 -05

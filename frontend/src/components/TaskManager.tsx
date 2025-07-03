"use client";

import { useState, useEffect } from 'react';
import { Task } from '@/types/task';
import { taskApi } from '@/lib/api';
import { TaskCard } from './TaskCard';
import { TaskForm } from './TaskForm';
import { Button } from './ui/Button';
import { Plus, RefreshCw } from 'lucide-react';

export function TaskManager() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | null>(null);
  const [error, setError] = useState<string | null>(null);

  const loadTasks = async () => {
    try {
      setLoading(true);
      setError(null);
      const fetchedTasks = await taskApi.getTasks();
      setTasks(fetchedTasks);
    } catch (err) {
      setError('Error al cargar las tareas. Por favor, intenta de nuevo.');
      console.error('Error loading tasks:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTasks();
  }, []);

  const handleCreateTask = async (taskData: { title: string; description: string }) => {
    try {
      const newTask = await taskApi.createTask(taskData);
      setTasks(prev => [newTask, ...prev]);
      setShowForm(false);
    } catch (err) {
      setError('Error al crear la tarea. Por favor, intenta de nuevo.');
      console.error('Error creating task:', err);
    }
  };

  const handleUpdateTask = async (id: number, taskData: { title: string; description: string; isCompleted: boolean }) => {
    try {
      const updatedTask = await taskApi.updateTask(id, taskData);
      setTasks(prev => prev.map(task => task.Id === id ? updatedTask : task));
      setEditingTask(null);
    } catch (err) {
      setError('Error al actualizar la tarea. Por favor, intenta de nuevo.');
      console.error('Error updating task:', err);
    }
  };

  const handleDeleteTask = async (id: number) => {
    if (!confirm('¿Estás seguro de que quieres eliminar esta tarea?')) {
      return;
    }
    
    try {
      await taskApi.deleteTask(id);
      setTasks(prev => prev.filter(task => task.Id !== id));
    } catch (err) {
      setError('Error al eliminar la tarea. Por favor, intenta de nuevo.');
      console.error('Error deleting task:', err);
    }
  };

  const handleToggleComplete = async (task: Task) => {
    await handleUpdateTask(task.Id, {
      title: task.Title,
      description: task.Description,
      isCompleted: !task.IsCompleted
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-64">
        <div className="flex items-center space-x-2">
          <RefreshCw className="h-6 w-6 animate-spin" />
          <span>Cargando tareas...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-md p-4">
          <p className="text-red-600">{error}</p>
          <Button 
            onClick={() => setError(null)} 
            variant="outline" 
            size="sm" 
            className="mt-2"
          >
            Cerrar
          </Button>
        </div>
      )}

      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Gestión de Tareas</h2>
          <p className="text-gray-600">
            {tasks.length} tarea{tasks.length !== 1 ? 's' : ''} en total
          </p>
        </div>
        
        <div className="flex space-x-2">
          <Button onClick={loadTasks} variant="outline">
            <RefreshCw className="h-4 w-4 mr-2" />
            Actualizar
          </Button>
          <Button onClick={() => setShowForm(true)}>
            <Plus className="h-4 w-4 mr-2" />
            Nueva Tarea
          </Button>
        </div>
      </div>

      {showForm && (
        <TaskForm
          onSubmit={handleCreateTask}
          onCancel={() => setShowForm(false)}
        />
      )}

      {editingTask && (
        <TaskForm
          task={editingTask}
          onSubmit={(data) => handleUpdateTask(editingTask.Id, { ...data, isCompleted: editingTask.IsCompleted })}
          onCancel={() => setEditingTask(null)}
        />
      )}

      <div className="grid gap-4">
        {tasks.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-gray-400 mb-4">
              <Plus className="h-12 w-12 mx-auto" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">No hay tareas</h3>
            <p className="text-gray-600 mb-4">Comienza creando tu primera tarea</p>
            <Button onClick={() => setShowForm(true)}>
              <Plus className="h-4 w-4 mr-2" />
              Crear Primera Tarea
            </Button>
          </div>
        ) : (
          tasks.map(task => (
            <TaskCard
              key={task.Id}
              task={task}
              onEdit={() => setEditingTask(task)}
              onDelete={() => handleDeleteTask(task.Id)}
              onToggleComplete={() => handleToggleComplete(task)}
            />
          ))
        )}
      </div>
    </div>
  );
}

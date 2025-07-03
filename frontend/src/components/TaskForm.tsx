"use client";

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Task } from '@/types/task';
import { Button } from './ui/Button';
import { Input } from './ui/Input';
import { Textarea } from './ui/Textarea';

interface TaskFormProps {
  task?: Task;
  onSubmit: (data: { title: string; description: string }) => void;
  onCancel: () => void;
}

interface FormData {
  title: string;
  description: string;
}

export function TaskForm({ task, onSubmit, onCancel }: TaskFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    defaultValues: {
      title: task?.Title || '',
      description: task?.Description || ''
    }
  });

  const onFormSubmit = async (data: FormData) => {
    setIsSubmitting(true);
    try {
      await onSubmit(data);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="bg-white rounded-lg border border-gray-200 p-6">
      <h3 className="text-lg font-semibold mb-4">
        {task ? 'Editar Tarea' : 'Nueva Tarea'}
      </h3>
      
      <form onSubmit={handleSubmit(onFormSubmit)} className="space-y-4">
        <div>
          <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-1">
            Título *
          </label>
          <Input
            id="title"
            {...register('title', { 
              required: 'El título es obligatorio',
              maxLength: { value: 200, message: 'El título no puede exceder 200 caracteres' }
            })}
            placeholder="Ingresa el título de la tarea"
            className={errors.title ? 'border-red-500' : ''}
          />
          {errors.title && (
            <p className="text-red-500 text-sm mt-1">{errors.title.message}</p>
          )}
        </div>

        <div>
          <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
            Descripción
          </label>
          <Textarea
            id="description"
            {...register('description', {
              maxLength: { value: 1000, message: 'La descripción no puede exceder 1000 caracteres' }
            })}
            placeholder="Ingresa la descripción de la tarea (opcional)"
            rows={3}
            className={errors.description ? 'border-red-500' : ''}
          />
          {errors.description && (
            <p className="text-red-500 text-sm mt-1">{errors.description.message}</p>
          )}
        </div>

        <div className="flex justify-end space-x-2 pt-4">
          <Button
            type="button"
            variant="outline"
            onClick={onCancel}
            disabled={isSubmitting}
          >
            Cancelar
          </Button>
          <Button
            type="submit"
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Guardando...' : (task ? 'Actualizar' : 'Crear')}
          </Button>
        </div>
      </form>
    </div>
  );
}

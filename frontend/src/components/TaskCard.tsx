import { Task } from '@/types/task';
import { Button } from './ui/Button';
import { Check, Edit, Trash2, Clock } from 'lucide-react';
import { cn } from '@/lib/utils';

interface TaskCardProps {
  task: Task;
  onEdit: () => void;
  onDelete: () => void;
  onToggleComplete: () => void;
}

export function TaskCard({ task, onEdit, onDelete, onToggleComplete }: TaskCardProps) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className={cn(
      "bg-white rounded-lg border border-gray-200 p-6 transition-all hover:shadow-md",
      task.IsCompleted && "bg-gray-50 border-gray-300"
    )}>
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center space-x-3 mb-2">
            <button
              onClick={onToggleComplete}
              className={cn(
                "flex items-center justify-center w-6 h-6 rounded-full border-2 transition-colors",
                task.IsCompleted
                  ? "bg-green-500 border-green-500 text-white"
                  : "border-gray-300 hover:border-green-500"
              )}
            >
              {task.IsCompleted && <Check className="h-4 w-4" />}
            </button>
            
            <h3 className={cn(
              "text-lg font-semibold",
              task.IsCompleted ? "text-gray-500 line-through" : "text-gray-900"
            )}>
              {task.Title}
            </h3>
            
            {task.IsCompleted && (
              <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                Completada
              </span>
            )}
          </div>

          {task.Description && (
            <p className={cn(
              "text-gray-600 mb-3",
              task.IsCompleted && "text-gray-400"
            )}>
              {task.Description}
            </p>
          )}

          <div className="flex items-center space-x-4 text-sm text-gray-500">
            <div className="flex items-center space-x-1">
              <Clock className="h-4 w-4" />
              <span>Creada: {formatDate(task.CreatedAt)}</span>
            </div>
            {task.UpdatedAt && (
              <div className="flex items-center space-x-1">
                <Clock className="h-4 w-4" />
                <span>Actualizada: {formatDate(task.UpdatedAt)}</span>
              </div>
            )}
          </div>
        </div>

        <div className="flex items-center space-x-2 ml-4">
          <Button
            onClick={onEdit}
            variant="outline"
            size="sm"
            className="text-blue-600 hover:text-blue-700 hover:bg-blue-50"
          >
            <Edit className="h-4 w-4" />
          </Button>
          <Button
            onClick={onDelete}
            variant="outline"
            size="sm"
            className="text-red-600 hover:text-red-700 hover:bg-red-50"
          >
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}

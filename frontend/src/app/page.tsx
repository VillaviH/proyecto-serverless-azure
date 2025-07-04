import { TaskManager } from '@/components/TaskManager';

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Sistema de Pruebas CRUD Serverless 
          </h1>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            Demostración de un sistema CRUD completo con Next.js, .NET Core 8 y Azure Serverless
          </p>
          <div className="mt-4 flex justify-center space-x-4 text-sm text-gray-500">
            <span className="flex items-center">
              <span className="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
              Frontend: Next.js 14
            </span>
            <span className="flex items-center">
              <span className="w-2 h-2 bg-blue-500 rounded-full mr-2"></span>
              Backend: .NET Core 8
            </span>
            <span className="flex items-center">
              <span className="w-2 h-2 bg-purple-500 rounded-full mr-2"></span>
              DB: Azure SQL
            </span>
          </div>
        </div>

        <TaskManager />
      </div>
    </main>
  );
}

package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/Sata51/sacre-tech-go-super-power/pkg/handler"
	"github.com/Sata51/sacre-tech-go-super-power/pkg/task"
)

// Middleware pour logger les requêtes
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s %v", r.Method, r.URL.Path, time.Since(start))
	})
}

// Middleware pour vérifier le content-type
func contentTypeMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "POST" || r.Method == "PUT" {
			if r.Header.Get("Content-Type") != "application/json" {
				http.Error(w, "Content-Type must be application/json", http.StatusUnsupportedMediaType)
				return
			}
		}
		next.ServeHTTP(w, r)
	})
}

func main() {
	// Initialisation du store et du handler
	store := task.NewTaskStore()
	taskHandler := &handler.TaskHandler{Store: store}
	echoHandler := &handler.EchoHandler{}

	// Configuration des routes
	mux := http.NewServeMux()
	mux.HandleFunc("/echo", echoHandler.Echo)
	mux.HandleFunc("/ohce", echoHandler.Ohce)
	mux.HandleFunc("/tasks", taskHandler.GetTasks)
	mux.HandleFunc("/task", taskHandler.CreateTask)

	// Application des middlewares
	httpHandler := loggingMiddleware(contentTypeMiddleware(mux))

	// Configuration du serveur
	server := &http.Server{
		Addr:         ":8080",
		Handler:      httpHandler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Démarrage du serveur dans une goroutine
	go func() {
		log.Printf("Starting server on :8080")
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server error: %v", err)
		}
	}()

	// Gestion gracieuse de l'arrêt
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt)
	<-stop

	log.Printf("Shutting down server...")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}
	log.Printf("Server stopped gracefully")
}

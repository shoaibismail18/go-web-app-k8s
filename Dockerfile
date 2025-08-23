#Build from golang image
FROM golang:1.22.5 AS base

#set the working directory inside the container
WORKDIR /app

#copy go mod to the directory
COPY go.mod .

#Download the dependencies
RUN go mod download


#copy the source code
COPY . .

#Build the application
RUN go build -o main .

# Final stage - distroless image
FROM gcr.io/distroless/base

#copy the built binary from the previous stage
COPY --from=base /app/main .

#copy static files
COPY --from=base app/static ./static

#Expose the port on which the app runs
EXPOSE 8080

#Command to run the executable
CMD ["./main"]


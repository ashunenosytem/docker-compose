FROM node:18
WORKDIR /app
COPY ExpenseTracker/backend/package*.json ./
RUN npm install
COPY ExpenseTracker/backend/ .
EXPOSE 5000
CMD ["npm", "start"]
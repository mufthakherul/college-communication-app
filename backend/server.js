const express = require('express');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Swagger configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Campus Mesh API',
      version: '1.0.0',
      description: 'A comprehensive college communication platform API built with Firebase Cloud Functions',
      contact: {
        name: 'Campus Mesh Team',
        email: 'support@campus-mesh.edu'
      }
    },
    servers: [
      {
        url: 'http://localhost:5001/campus-mesh-dev/us-central1',
        description: 'Development server (Firebase Functions)'
      },
      {
        url: 'https://us-central1-campus-mesh-staging.cloudfunctions.net',
        description: 'Staging server'
      },
      {
        url: 'https://us-central1-campus-mesh-prod.cloudfunctions.net',
        description: 'Production server'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Firebase ID Token'
        }
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            error: {
              type: 'object',
              properties: {
                code: {
                  type: 'string',
                  example: 'invalid-argument'
                },
                message: {
                  type: 'string',
                  example: 'Invalid input parameters'
                }
              }
            }
          }
        },
        SuccessResponse: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: true
            }
          }
        }
      }
    },
    security: [
      {
        bearerAuth: []
      }
    ]
  },
  apis: ['./routes/*.js'], // Path to the API files
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

// Import routes
const usersRoutes = require('./routes/users');
const groupsRoutes = require('./routes/groups');
const messagesRoutes = require('./routes/messages');

// Use routes
app.use('/users', usersRoutes);
app.use('/groups', groupsRoutes);
app.use('/messages', messagesRoutes);

// Swagger UI route
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customSiteTitle: 'Campus Mesh API Documentation',
  customCss: '.swagger-ui .topbar { display: none }',
  swaggerOptions: {
    persistAuthorization: true,
  }
}));

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Campus Mesh API Documentation Server',
    documentation: '/api-docs',
    status: 'running'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Campus Mesh API Documentation Server running on port ${PORT}`);
  console.log(`📚 API Documentation available at: http://localhost:${PORT}/api-docs`);
});

module.exports = app;
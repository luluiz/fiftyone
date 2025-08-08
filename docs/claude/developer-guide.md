# Developer Guide

This guide provides comprehensive information for developers working on FiftyOne or building extensions.

## Development Environment Setup

### Prerequisites

- Python 3.7+
- Node.js 16+
- Yarn package manager
- MongoDB 4.4+
- Git

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/voxel51/fiftyone.git
   cd fiftyone
   ```

2. **Set up Python environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -e .
   pip install -r requirements/dev.txt
   ```

3. **Set up frontend environment**:
   ```bash
   cd app
   yarn install
   cd ..
   ```

4. **Install MongoDB**:
   ```bash
   # macOS with Homebrew
   brew tap mongodb/brew
   brew install mongodb-community
   
   # Ubuntu
   sudo apt-get install mongodb
   
   # Start MongoDB
   brew services start mongodb-community  # macOS
   sudo systemctl start mongod            # Ubuntu
   ```

### Environment Configuration

Create a `.env` file in the project root:

```bash
# Database
FIFTYONE_DATABASE_URI=mongodb://localhost:27017
FIFTYONE_DATABASE_NAME=fiftyone_dev

# App
FIFTYONE_APP_PORT=5151
FIFTYONE_APP_ALLOW_MEDIA_EXPORT=true

# Development
FIFTYONE_DEVELOPMENT=true
FIFTYONE_LOG_LEVEL=DEBUG
```

## Build Process

### Backend Build

The backend is a Python package that doesn't require compilation:

```bash
# Install in development mode
pip install -e .

# Run tests
pytest tests/

# Generate documentation
cd docs
make html
```

### Frontend Build

The frontend uses Vite for building:

```bash
cd app

# Development server
yarn dev

# Production build
yarn build

# Type checking
yarn type-check

# Linting
yarn lint
```

### Full Application Build

```bash
# Build everything
make build

# Run development server
fiftyone app launch --port 5151
```

## Testing

### Backend Testing

```bash
# Unit tests
pytest tests/unittests/

# Integration tests
pytest tests/intensive/

# Specific test
pytest tests/unittests/test_dataset.py::TestDataset::test_add_sample

# With coverage
pytest --cov=fiftyone tests/
```

### Frontend Testing

```bash
cd app

# Unit tests
yarn test

# E2E tests
yarn test:e2e

# Watch mode
yarn test:watch

# Coverage
yarn test:coverage
```

### Test Database

Use a separate database for testing:

```bash
export FIFTYONE_DATABASE_NAME=fiftyone_test
pytest tests/
```

## Code Style and Standards

### Python Code Style

FiftyOne follows PEP 8 with some modifications:

```bash
# Format code
black fiftyone/

# Lint code
pylint fiftyone/

# Sort imports
isort fiftyone/

# Type checking
mypy fiftyone/
```

**Configuration files**:
- `pyproject.toml`: Black and isort configuration
- `pylintrc`: Pylint configuration
- `mypy.ini`: MyPy type checking configuration

### Frontend Code Style

```bash
cd app

# Format code
yarn prettier

# Lint code
yarn lint

# Fix linting issues
yarn lint:fix
```

**Configuration files**:
- `.eslintrc.js`: ESLint configuration
- `.prettierrc.js`: Prettier configuration
- `tsconfig.json`: TypeScript configuration

## Architecture Deep Dive

### Backend Architecture

```
fiftyone/
├── core/           # Core functionality
│   ├── dataset.py  # Dataset management
│   ├── models.py   # Model interface
│   ├── session.py  # App sessions
│   └── view.py     # Dataset views
├── server/         # Web server
│   ├── main.py     # FastAPI app
│   ├── graphql/    # GraphQL schema
│   └── routes/     # REST endpoints
├── utils/          # Utility modules
│   ├── torch.py    # PyTorch utilities
│   ├── data.py     # Data handling
│   └── eval.py     # Evaluation metrics
└── zoo/            # Model zoo
    ├── models/     # Model definitions
    └── datasets/   # Dataset zoo
```

### Frontend Architecture

```
app/
├── packages/
│   ├── core/       # Core utilities
│   ├── state/      # Recoil state management
│   ├── components/ # React components
│   ├── relay/      # GraphQL client
│   └── app/        # Main application
├── public/         # Static assets
└── __mocks__/      # Test mocks
```

## Plugin Development

### Creating a Custom Operator

```python
import fiftyone.operators as foo
import fiftyone.operators.types as types

class CustomAnalysisOperator(foo.Operator):
    @property
    def config(self):
        return foo.OperatorConfig(
            name="custom_analysis",
            label="Custom Analysis",
            description="Performs custom analysis on samples",
        )

    def resolve_input(self, ctx):
        inputs = types.Object()
        inputs.str("analysis_type", label="Analysis Type")
        inputs.int("threshold", label="Threshold", default=10)
        return types.Property(inputs)

    def execute(self, ctx):
        analysis_type = ctx.params.get("analysis_type")
        threshold = ctx.params.get("threshold", 10)
        
        # Perform analysis
        results = self._analyze_samples(ctx.dataset, analysis_type, threshold)
        
        return {"results": results}

    def _analyze_samples(self, dataset, analysis_type, threshold):
        # Custom analysis logic
        return {"count": len(dataset)}

# Register the operator
def register_plugin():
    foo.register_operator(CustomAnalysisOperator)
```

### Creating a Custom Panel

```typescript
// app/packages/panels/src/CustomPanel.tsx
import React from 'react';
import { Panel } from '@fiftyone/components';

interface CustomPanelProps {
  dataset: Dataset;
  samples: Sample[];
}

const CustomPanel: React.FC<CustomPanelProps> = ({ dataset, samples }) => {
  return (
    <Panel title="Custom Analysis">
      <div>
        <h3>Dataset: {dataset.name}</h3>
        <p>Sample count: {samples.length}</p>
        {/* Custom panel content */}
      </div>
    </Panel>
  );
};

export default CustomPanel;
```

Register the panel:

```typescript
// app/packages/panels/src/index.ts
import { registerPanel } from '@fiftyone/core';
import CustomPanel from './CustomPanel';

registerPanel({
  name: 'custom-analysis',
  component: CustomPanel,
  label: 'Custom Analysis',
});
```

## Contributing Guidelines

### Git Workflow

1. **Fork the repository** on GitHub
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/my-feature
   ```
3. **Make changes** and commit:
   ```bash
   git add .
   git commit -m "Add my feature"
   ```
4. **Push to your fork**:
   ```bash
   git push origin feature/my-feature
   ```
5. **Create a Pull Request** on GitHub

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/modifications
- `chore`: Maintenance tasks

Example:
```
feat(core): add support for video keyframes

Add ability to extract and analyze keyframes from video samples.
Includes new VideoKeyframe label type and extraction utilities.

Closes #1234
```

### Pull Request Guidelines

1. **Update documentation** for new features
2. **Add tests** for new functionality
3. **Follow code style** guidelines
4. **Update CHANGELOG** if applicable
5. **Ensure CI passes** all checks

### Code Review Process

1. **Automated checks**: CI must pass
2. **Code review**: At least one reviewer approval
3. **Documentation review**: For user-facing changes
4. **Testing review**: Adequate test coverage

## Release Process

### Version Management

FiftyOne uses semantic versioning (SemVer):

- **Major** (X.0.0): Breaking changes
- **Minor** (X.Y.0): New features, backward compatible
- **Patch** (X.Y.Z): Bug fixes

### Release Steps

1. **Update version numbers**:
   ```bash
   # Update version in setup.py and package.json
   # Update CHANGELOG.md
   ```

2. **Create release branch**:
   ```bash
   git checkout -b release/v0.X.Y
   ```

3. **Final testing**:
   ```bash
   pytest tests/
   cd app && yarn test
   ```

4. **Tag release**:
   ```bash
   git tag v0.X.Y
   git push origin v0.X.Y
   ```

5. **Build and publish**:
   ```bash
   python setup.py sdist bdist_wheel
   twine upload dist/*
   ```

## Debugging

### Backend Debugging

```python
# Enable debug logging
import logging
logging.basicConfig(level=logging.DEBUG)

# Use debugger
import pdb; pdb.set_trace()

# Or use ipdb for better interface
import ipdb; ipdb.set_trace()
```

### Frontend Debugging

```typescript
// Use React DevTools
// Available as browser extension

// Console debugging
console.log('Debug info:', data);
console.table(arrayData);

// Breakpoints in browser DevTools
debugger;
```

### Common Issues

1. **MongoDB connection issues**:
   ```bash
   # Check if MongoDB is running
   brew services list | grep mongodb
   
   # Restart MongoDB
   brew services restart mongodb-community
   ```

2. **Port conflicts**:
   ```bash
   # Find process using port
   lsof -i :5151
   
   # Kill process
   kill -9 <PID>
   ```

3. **Frontend build issues**:
   ```bash
   cd app
   rm -rf node_modules
   yarn install
   ```

## Performance Optimization

### Backend Performance

1. **Database indexing**:
   ```python
   # Create indexes for frequently queried fields
   dataset._sample_collection.create_index("filepath")
   dataset._sample_collection.create_index("metadata.width")
   ```

2. **Batch operations**:
   ```python
   # Use batch operations for bulk updates
   dataset.add_samples(samples, expand_schema=False)
   ```

3. **Memory management**:
   ```python
   # Clear unused datasets
   fo.delete_dataset("unused_dataset")
   
   # Use views instead of copying data
   view = dataset.limit(100)
   ```

### Frontend Performance

1. **Component memoization**:
   ```typescript
   const MemoizedComponent = React.memo(Component);
   ```

2. **Virtual scrolling**:
   ```typescript
   // Use react-window for large lists
   import { FixedSizeList } from 'react-window';
   ```

3. **Bundle optimization**:
   ```javascript
   // Dynamic imports
   const Component = lazy(() => import('./Component'));
   ```

## Security Considerations

### Backend Security

1. **Input validation**:
   ```python
   from marshmallow import Schema, fields
   
   class SampleSchema(Schema):
       filepath = fields.Str(required=True)
       confidence = fields.Float(validate=lambda x: 0 <= x <= 1)
   ```

2. **Authentication**:
   ```python
   # Implement JWT authentication
   from jose import JWTError, jwt
   ```

### Frontend Security

1. **XSS Prevention**:
   ```typescript
   // Sanitize user input
   import DOMPurify from 'dompurify';
   const clean = DOMPurify.sanitize(dirty);
   ```

2. **CSRF Protection**:
   ```typescript
   // Include CSRF tokens in requests
   const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
   ```

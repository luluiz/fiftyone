# Frontend Documentation

FiftyOne's frontend is a modern React-based web application that provides an intuitive interface for dataset visualization and analysis.

## Architecture Overview

The frontend follows a component-based architecture using React with TypeScript:

- **React Components**: Modular UI components
- **Recoil**: State management for global application state
- **Relay**: GraphQL client for efficient data fetching
- **Material-UI**: Component library for consistent styling

## Core Components

### App Container
The main application container that orchestrates:
- Session management
- Route handling
- Global state initialization
- Error boundaries

### Dataset Viewer
Central component for dataset visualization:
- Grid view for image/video samples
- Detailed sample view
- Label overlays and annotations
- Metadata display

### Filters Panel
Advanced filtering interface:
- Field-based filters
- Label-type filters
- Custom query builder
- Filter history and saved views

### Sample Modal
Detailed view for individual samples:
- Full-resolution media display
- Label editing capabilities
- Metadata inspection
- Navigation between samples

## State Management

### Recoil Architecture

FiftyOne uses Recoil for state management with atoms and selectors:

```typescript
// Dataset state atom
const datasetAtom = atom({
  key: 'dataset',
  default: null,
});

// Filtered samples selector
const filteredSamplesSelector = selector({
  key: 'filteredSamples',
  get: ({get}) => {
    const dataset = get(datasetAtom);
    const filters = get(filtersAtom);
    return applyFilters(dataset, filters);
  },
});
```

### State Categories

1. **Dataset State**: Current dataset and view information
2. **UI State**: Modal visibility, selected samples, etc.
3. **Filter State**: Active filters and search parameters
4. **User Preferences**: Theme, layout settings, etc.

## Data Fetching with Relay

FiftyOne uses Relay for efficient GraphQL data fetching:

```typescript
// GraphQL fragment for sample data
const SampleFragment = graphql`
  fragment Sample_sample on Sample {
    id
    filepath
    metadata {
      width
      height
    }
    labels {
      ...Label_label
    }
  }
`;

// Query hook
const useSamples = () => {
  return useLazyLoadQuery(
    graphql`
      query SamplesQuery($first: Int, $after: String) {
        samples(first: $first, after: $after) {
          edges {
            node {
              ...Sample_sample
            }
          }
        }
      }
    `,
    { first: 20 }
  );
};
```

## Component Library

### Core Components

1. **Sample Grid**: Virtualized grid for displaying sample thumbnails
2. **Sample Card**: Individual sample representation
3. **Label Overlay**: Visual representation of annotations
4. **Filter Builder**: Dynamic filter construction interface

### Utility Components

1. **Loading Indicators**: Progress bars and spinners
2. **Error Boundaries**: Graceful error handling
3. **Modal System**: Reusable modal components
4. **Toast Notifications**: User feedback system

## Routing

FiftyOne uses React Router for client-side navigation:

```typescript
// Route configuration
const routes = [
  {
    path: '/datasets/:name',
    element: <DatasetView />,
  },
  {
    path: '/datasets/:name/samples/:id',
    element: <SampleDetail />,
  },
];
```

## User Interface Guidelines

### Design System

- **Color Palette**: Consistent color scheme across components
- **Typography**: Hierarchical text styling
- **Spacing**: Standardized margins and padding
- **Icons**: Consistent iconography

### Responsive Design

- Mobile-first approach
- Flexible grid layouts
- Adaptive component sizing
- Touch-friendly interactions

### Accessibility

- ARIA labels and roles
- Keyboard navigation support
- Screen reader compatibility
- High contrast mode support

## Performance Optimization

### Virtualization
- Virtual scrolling for large datasets
- Lazy loading of sample thumbnails
- Efficient rendering of grid components

### Caching
- GraphQL query caching with Relay
- Image thumbnail caching
- Component memoization

### Bundle Optimization
- Code splitting by route
- Dynamic imports for large components
- Tree shaking for unused code
- Asset optimization

## Development Workflow

### Build Process
```bash
# Development server
yarn dev

# Production build
yarn build

# Type checking
yarn type-check

# Linting
yarn lint
```

### Testing
- Unit tests with Jest
- Component testing with React Testing Library
- E2E tests with Playwright
- Visual regression testing

### Code Quality
- ESLint for code standards
- Prettier for formatting
- TypeScript for type safety
- Husky for pre-commit hooks

## Plugin Development

### Panel Plugins
Custom UI panels can be added to extend functionality:

```typescript
interface PanelProps {
  dataset: Dataset;
  samples: Sample[];
}

const CustomPanel: React.FC<PanelProps> = ({ dataset, samples }) => {
  return (
    <div>
      <h3>Custom Analysis</h3>
      {/* Custom panel content */}
    </div>
  );
};

// Register panel
registerPanel('custom-analysis', CustomPanel);
```

### Component Extensions
- Custom visualizers for new label types
- Custom filters for specialized use cases
- Custom sample renderers for different media types

## Browser Compatibility

### Supported Browsers
- Chrome 80+
- Firefox 75+
- Safari 13+
- Edge 80+

### Feature Detection
- Progressive enhancement for advanced features
- Fallbacks for unsupported APIs
- Polyfills for older browsers

## Security Considerations

### Data Protection
- Secure token-based authentication
- HTTPS enforcement
- Content Security Policy (CSP)
- XSS protection

### API Security
- GraphQL query validation
- Rate limiting
- Input sanitization
- CORS configuration

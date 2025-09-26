# Statistics System - Spider Web Chart

## Overview
The statistics system provides a visual spider web (radar chart) that displays user performance across five key cognitive areas based on their quiz results and training activities stored in Firestore.

## Categories and Mappings

The spider web chart displays performance in five categories:

1. **Understanding** (Level 1) - Light Blue
   - Based on Quiz 1 results
   - Calculated from accuracy percentage

2. **Solving** (Level 2) - Pink  
   - Based on Quiz 2 results
   - Calculated from accuracy percentage

3. **Patterns** (Level 3) - Teal
   - Based on Quiz 3 results
   - Calculated from accuracy percentage

4. **Memory** (Level 4) - Purple
   - Based on Quiz 4 results
   - Calculated from accuracy percentage

5. **Logic** (Training) - Yellow
   - Based on level_page training results
   - Calculated from points efficiency (points per second)

## How It Works

### Data Sources
- **Quiz Results**: Stored in `users/{uid}/quiz_results` collection
- **Training Results**: Stored in `users/{uid}/level_page` collection

### Calculation Logic

#### Quiz-based Categories (Understanding, Solving, Patterns, Memory)
```dart
// For each quiz level, calculate average accuracy
double accuracy = correct_answers / total_questions;
// Average across all attempts for that level
double categoryScore = average_accuracy.clamp(0.0, 1.0);
```

#### Training Category (Logic)
```dart
// Calculate efficiency based on points per second
double efficiency = points_collected / time_taken_seconds;
// Normalize to 0-1 range (assuming max 1.67 points/sec)
double normalizedEfficiency = (efficiency / 1.67).clamp(0.0, 1.0);
```

### Display
- Values are normalized to 0.0 - 1.0 range
- Displayed as percentages (0% - 100%)
- Spider web chart shows relative performance
- Additional stat cards show individual category scores

## Files Modified

1. **lib/services/statistics_service.dart** - New service for data calculation
2. **lib/features/profile/profile.dart** - Updated StatisticsPage to use real data

## Usage

The statistics page is accessible through:
Profile → Statistics

The page automatically loads user data from Firestore and displays:
- Interactive spider web chart
- Individual category performance cards
- Real-time updates when data changes

## Future Enhancements

- Add historical trend charts
- Include more detailed breakdowns
- Add comparison with other users
- Implement achievement badges based on statistics

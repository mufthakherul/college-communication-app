# Gradle afterEvaluate Fix

## Issue
The Flutter Android build was failing with the following error:
```
FAILURE: Build failed with an exception.
* Where:
Build file '/home/runner/work/college-communication-app/college-communication-app/apps/mobile/android/build.gradle' line: 40
* What went wrong:
A problem occurred evaluating root project 'android'.
> Cannot run Project.afterEvaluate(Closure) when the project is already evaluated.
```

## Root Cause
The `apps/mobile/android/build.gradle` file had two conflicting `subprojects` blocks:

### Block 1 (Lines 23-28, now removed):
```gradle
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')  // This was the problem!
}
```

### Block 2 (Lines 39-53, still present):
```gradle
subprojects { subproject ->
    afterEvaluate {
        if (subproject.plugins.hasPlugin('com.android.library')) {
            android {
                if (namespace == null) {
                    def pluginNamespace = pluginNamespaces[subproject.name]
                    if (pluginNamespace != null) {
                        namespace pluginNamespace
                    }
                }
            }
        }
    }
}
```

## Why This Failed
1. **`evaluationDependsOn(':app')`** forces the `:app` project to be evaluated immediately
2. Since other subprojects depend on `:app`, they also get evaluated immediately
3. When Gradle reaches the second `subprojects` block, all projects have already been evaluated
4. **`afterEvaluate`** can only be registered BEFORE a project is evaluated
5. Trying to register `afterEvaluate` on an already-evaluated project causes the error

## Solution
Removed the `subprojects { project.evaluationDependsOn(':app') }` block from the build.gradle file.

### What Was Removed:
```gradle
subprojects {
    project.evaluationDependsOn(':app')
}
```

### Why This Is Safe:
- The `evaluationDependsOn(':app')` was unnecessary
- The namespace configuration in the `afterEvaluate` block doesn't require it
- Gradle will naturally evaluate projects in the correct order
- The `afterEvaluate` hook will still trigger at the right time for each subproject

## Result
After this fix:
- ✅ The Gradle configuration is no longer conflicting
- ✅ The `afterEvaluate` block can register properly on each subproject
- ✅ The namespace assignment for plugins (documented in NAMESPACE_FIX.md) continues to work correctly
- ✅ The build process can proceed normally

## Testing
To verify the fix:
```bash
cd apps/mobile
flutter build apk --debug
```

The build should now proceed past the Gradle configuration phase without the "Cannot run Project.afterEvaluate" error.

## Related Documentation
- [NAMESPACE_FIX.md](NAMESPACE_FIX.md) - Documents the namespace configuration that uses `afterEvaluate`
- [APK_BUILD_GUIDE.md](APK_BUILD_GUIDE.md) - Instructions for building APK files
- [Gradle Project API - afterEvaluate](https://docs.gradle.org/current/javadoc/org/gradle/api/Project.html#afterEvaluate-groovy.lang.Closure-)
- [Gradle Project API - evaluationDependsOn](https://docs.gradle.org/current/javadoc/org/gradle/api/Project.html#evaluationDependsOn-java.lang.String-)

## Additional Notes
This is a minimal, surgical fix that:
- Changes only 3 lines (removes a small configuration block)
- Doesn't affect any other build configuration
- Maintains all existing functionality
- Resolves the immediate build failure

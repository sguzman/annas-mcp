#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <add|delete|recreate>"
    echo "  add      - Create and push a new tag"
    echo "  delete   - Delete the tag locally and from GitHub"
    echo "  recreate - Delete and recreate the tag"
    exit 1
fi

ACTION=$1

if [ "$ACTION" != "add" ] && [ "$ACTION" != "delete" ] && [ "$ACTION" != "recreate" ]; then
    echo "Error: Invalid action. Use 'add', 'delete', or 'recreate'"
    exit 1
fi

if [ ! -f "internal/version/version.txt" ]; then
    echo "Error: internal/version/version.txt file not found"
    exit 1
fi

VERSION=$(cat internal/version/version.txt | tr -d '[:space:]')

if [ -z "$VERSION" ]; then
    echo "Error: version.txt is empty"
    exit 1
fi

case "$ACTION" in
    "add")
        echo "Creating and pushing tag: $VERSION"
        
        git tag "$VERSION"
        
        if [ $? -eq 0 ]; then
            echo "Tag $VERSION created successfully"
            
            git push origin "$VERSION"
            
            if [ $? -eq 0 ]; then
                echo "Tag $VERSION pushed to GitHub successfully"
            else
                echo "Error: Failed to push tag $VERSION to GitHub"
                exit 1
            fi
        else
            echo "Error: Failed to create tag $VERSION"
            exit 1
        fi
        ;;
        
    "delete")
        echo "Deleting tag: $VERSION"
        
        git tag -d "$VERSION"
        
        if [ $? -eq 0 ]; then
            echo "Local tag $VERSION deleted successfully"
            
            git push origin --delete "$VERSION"
            
            if [ $? -eq 0 ]; then
                echo "Remote tag $VERSION deleted from GitHub successfully"
            else
                echo "Error: Failed to delete remote tag $VERSION from GitHub"
                exit 1
            fi
        else
            echo "Error: Failed to delete local tag $VERSION"
            exit 1
        fi
        ;;
        
    "recreate")
        echo "Recreating tag: $VERSION"
        
        echo "Step 1: Deleting existing tag..."
        git tag -d "$VERSION" 2>/dev/null
        git push origin --delete "$VERSION" 2>/dev/null
        
        echo "Step 2: Creating new tag..."
        git tag "$VERSION"
        
        if [ $? -eq 0 ]; then
            echo "Tag $VERSION created successfully"
            
            git push origin "$VERSION"
            
            if [ $? -eq 0 ]; then
                echo "Tag $VERSION recreated and pushed to GitHub successfully"
            else
                echo "Error: Failed to push tag $VERSION to GitHub"
                exit 1
            fi
        else
            echo "Error: Failed to create tag $VERSION"
            exit 1
        fi
        ;;
esac
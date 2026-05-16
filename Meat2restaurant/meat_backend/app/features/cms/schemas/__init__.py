from .cms import (
    WebPageCreate, WebPageUpdate, WebPageOut, WebPageVersionOut,
    BlogPostCreate, BlogPostUpdate, BlogPostOut, BlogPostVersionOut,
    RecipeCreate, RecipeUpdate, RecipeOut, RecipeIngredientOut, RecipeStepOut,
    FAQCreate, FAQUpdate, FAQOut
)

# Compatibility Aliases
WebPage = WebPageOut
BlogPost = BlogPostOut
Recipe = RecipeOut
FAQ = FAQOut

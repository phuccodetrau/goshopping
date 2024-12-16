erDiagram
    User {
        String email
        String password
        String name
        String language
        String timezone
        String device
        String image
        Date verificationCodeExpires
        String verificationCode
    }

    GroupUser {
        String name
        String email
        String role
    }

    Group {
        String name
        String image
    }

    Category {
        String name
    }

    Unit {
        String name
    }

    Food {
        String name
        String categoryName
        String unitName
        String image
    }

    Item {
        String foodName
        Date expireDate
        Number amount
        String unitName
        String note
    }

    ListTask {
        String name
        String memberEmail
        String note
        Date startDate
        Date endDate
        String foodName
        Number amount
        String unitName
        Boolean state
    }

    RecipeItem {
        String foodName
        Number amount
    }

    Recipe {
        String name
        String description
    }

    MealPlan {
        Date date
        String course
    }

    User ||--o| GroupUser : belongs_to
    GroupUser }|--|{ Group : member_of
    Group ||--o| Item : has
    Group ||--o| ListTask : assigns
    Group ||--o| Recipe : creates
    Group ||--o| MealPlan : has
    Category ||--o| Food : categorizes
    Unit ||--o| Food : measures
    Food ||--o| Item : consists_of
    Food ||--o| RecipeItem : used_in
    Recipe ||--o| RecipeItem : consists_of
    MealPlan ||--o| Recipe : includes
    ListTask ||--o| Food : involves

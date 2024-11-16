import mongoose from 'mongoose';
const { Schema } = mongoose;

const userSchema = new Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: { type: String,},
  language: { type: String },
  timezone: { type: String },
  device: { type: String },
  image: { type: String },
  verificationCodeExpires:{type:Date},
  verificationCode:{type:String}
});

const categorySchema = new Schema({
  name: { type: String, required: true },
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true }
});

const unitSchema = new Schema({
  name: { type: String, required: true },
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true }
});

const foodSchema = new Schema({
  name: { type: String, required: true },
  categoryName: { type: String, required: true },
  unitName: { type: String, required: true },
  image: { type: String },
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true }
});

const itemSchema = new Schema({
  foodName: { type: String, required: true },
  expireDate: { type: Date, required: true },
  amount: { type: Number, required: true },
  note: { type: Number },
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true }
});

const listTaskItemSchema = new Schema({
  foodName: { type: String, required: true },
  amount: { type: Number, required: true }
});

const listTaskSchema = new Schema({
  name: { type: String, required: true },
  memberEmail: { type: String, required: true },
  note: { type: String },
  date: { type: Date, required: true },
  list_item: [listTaskItemSchema],
  state: { type: Boolean, default: false },
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true }
});

const recipeItemSchema = new Schema({
  foodName: { type: String, required: true },
  amount: { type: Number, required: true }
});

const recipeSchema = new Schema({
  name: { type: String, required: true },
  description: { type: String },
  list_item: [recipeItemSchema],
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true }
});

const mealPlanSchema = new Schema({
  date: { type: Date, required: true },
  course: { type: String, required: true },
  listRecipe: [{ type: Schema.Types.ObjectId, ref: 'Recipe' }],
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true }
});

const groupUserSchema = new Schema({
  name: { type: String, required: true },
  email: { type: String, required: true },
  role: { type: String, required: true }
});

const groupSchema = new Schema({
  name: { type: String, required: true },
  listUser: [groupUserSchema],
  refrigerator: [itemSchema],
  image: { type: String } 
});


export const User = mongoose.model('User', userSchema);
export const Category = mongoose.model('Category', categorySchema);
export const Unit = mongoose.model('Unit', unitSchema);
export const Food = mongoose.model('Food', foodSchema);
export const Item = mongoose.model('Item', itemSchema);
export const ListTask = mongoose.model('ListTask', listTaskSchema);
export const Recipe = mongoose.model('Recipe', recipeSchema);
export const MealPlan = mongoose.model('MealPlan', mealPlanSchema);
export const Group = mongoose.model('Group', groupSchema);

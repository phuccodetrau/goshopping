import mongoose from 'mongoose';
const { Schema } = mongoose;

const userSchema = new Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: { type: String },
  phoneNumber: { type: String },
  avatar: { type: String},
  language: { type: String },
  timezone: { type: String },
  device: { type: String },
  verificationCodeExpires: { type: Date },
  verificationCode: { type: String },
  deviceToken: { type: String },
}, {
  timestamps: true,
  toJSON: {
    virtuals: true,
    transform: function(doc, ret) {
      if (ret.avatar && ret.avatar.data) {
        ret.avatarUrl = `/api/user/get-avatar/${ret.email}`;
      } else {
        ret.avatarUrl = null;
      }
      if (ret.avatar) {
        delete ret.avatar.data;
      }
      return ret;
    }
  }
});

userSchema.virtual('avatarUrl').get(function() {
  if (this.avatar && this.avatar.data) {
    return `/api/user/get-avatar/${this.email}`;
  }
  return null;
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
  unitName: { type: String, required: true },
  note: { type: String },
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true }
});

const listTaskSchema = new Schema({
  name: { type: String, required: true },
  memberEmail: { type: String, required: true },
  note: { type: String },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  foodName: { type: String, required: true },
  amount: { type: Number, required: true },
  unitName: { type: String, required: true },
  state: { type: Boolean, default: false },
  group: { type: Schema.Types.ObjectId, ref: 'Group', required: true },
  price: { type: Number, default: 0 },
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
  avatar: { type: String } 
});

const notificationSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, required: true },
  content: { type: String, required: true },
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
}, {
  timestamps: true
});
const adminSchema=new Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
})
export const User = mongoose.model('User', userSchema);
export const Category = mongoose.model('Category', categorySchema);
export const Unit = mongoose.model('Unit', unitSchema);
export const Food = mongoose.model('Food', foodSchema);
export const Item = mongoose.model('Item', itemSchema);
export const ListTask = mongoose.model('ListTask', listTaskSchema);
export const Recipe = mongoose.model('Recipe', recipeSchema);
export const MealPlan = mongoose.model('MealPlan', mealPlanSchema);
export const Group = mongoose.model('Group', groupSchema);
export const Notification = mongoose.model('Notification', notificationSchema);
export const Admin=mongoose.model("Admin",adminSchema)

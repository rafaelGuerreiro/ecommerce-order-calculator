[![Build Status](https://travis-ci.org/rafaelGuerreiro/ecommerce-order-calculator.svg?branch=master)](https://travis-ci.org/rafaelGuerreiro/ecommerce-order-calculator)
[![Code Climate](https://codeclimate.com/github/rafaelGuerreiro/ecommerce-order-calculator/badges/gpa.svg)](https://codeclimate.com/github/rafaelGuerreiro/ecommerce-order-calculator)
[![Test Coverage](https://codeclimate.com/github/rafaelGuerreiro/ecommerce-order-calculator/badges/coverage.svg)](https://codeclimate.com/github/rafaelGuerreiro/ecommerce-order-calculator/coverage)
[![Issue Count](https://codeclimate.com/github/rafaelGuerreiro/ecommerce-order-calculator/badges/issue_count.svg)](https://codeclimate.com/github/rafaelGuerreiro/ecommerce-order-calculator)

#e-commerce order calculator

##Important note

this software is supposed to run on ruby >= 2.1

###Installing

- Clone this repository in a desired folder.
```
git clone https://github.com/rafaelGuerreiro/ecommerce-order-calculator.git
```

- Move into the new folder using `cd ecommerce-order-calculator`
- Install required gems using `bundle install`

###Running

- Locate the csv files needed to run this software. Let's assume that they are in your Desktop:
  - /Users/your-user/Desktop/coupons.csv
  - /Users/your-user/Desktop/products.csv
  - /Users/your-user/Desktop/orders.csv
  - /Users/your-user/Desktop/order_items.csv

- To execute this software, run the following command:
```
./app.rb /Users/your-user/Desktop/coupons /Users/your-user/Desktop/products /Users/your-user/Desktop/orders /Users/your-user/Desktop/order_items /Users/your-user/Desktop/result
```
  You can also run the above command using relative paths.
  So, if you placed the `ecommerce-order-calculator` in your Desktop as well it would be like this:
```
./app.rb ../coupons ../products.csv ../orders ../order_items.csv ../result
```
  As you might have noticed, the `.csv` extension is optional when you're executing `app.rb`

- Check the `result.csv` generated by the software.

####Issues

- If you forget to inform one CSV file, the software will complaint about it.
```
FATAL ERROR => You have to provide 5 paths for the program be able to continue.
The order of models being used is: [Coupon, Product, Order, OrderProduct, :result]
```

- Your user have to have writing permissions to the target directory so the software can run correctly.

###Testing

In order to test this software, you can run `rspec`, or `rspec -f d` to see the documentation.

###Ruby style guide

This software was intended to follow ruby style guide, run `rubocop` to check it.

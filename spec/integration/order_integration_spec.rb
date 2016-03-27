require 'byebug'

describe Order, :integration do
  before do
    [
      { model: Order, file_path: 'orders' },
      { model: Coupon, file_path: 'coupons' },
      { model: OrderProduct, file_path: 'order_items' },
      { model: Product, file_path: 'products' }
    ].each do |csv|
      path = File.join('..', 'csvs', csv[:file_path])
      path = File.expand_path(path, __FILE__)

      csv[:model].load(path)
    end
  end

  it 'has 2 products and no coupon based on OrderProduct model for order 123' do
    order = Order.find(123)

    expect(order.products).to have(2).products
    expect(order.products.map(&:value))
      .to contain_exactly(2_400, 100)

    expect(order.coupon_id).to be_nil
    expect(order.coupon).to be_nil

    expect(order.total).to eq(2_500)
    expect(order.total_with_discount).to eq(2_250)
  end

  it 'has 3 products and a coupon based on OrderProduct model for order 234' do
    order = Order.find(234)

    expect(order.products).to have(3).products
    expect(order.products.map(&:value))
      .to contain_exactly(75, 80, 100)

    expect(order.coupon_id).to eq(123)
    expect(order.coupon).to_not be_nil
    expect(order.coupon.value).to eq(25)
    expect(order.coupon.discount_type).to eq(:absolute)
    expect(order.coupon.usage_limit).to eq(1)
    expect(order.coupon.expired?).to be_falsy

    expect(order.total).to eq(255)
    expect(order.total_with_discount).to eq(216.75)

    expect(order.coupon.usage_limit).to eq(1)
  end

  it 'has 2 products and a coupon based on OrderProduct model for order 345' do
    order = Order.find(345)

    expect(order.products).to have(2).products
    expect(order.products.map(&:value))
      .to contain_exactly(250, 120)

    expect(order.coupon_id).to eq(234)
    expect(order.coupon).to_not be_nil
    expect(order.coupon.value).to eq(15)
    expect(order.coupon.discount_type).to eq(:percent)
    expect(order.coupon.usage_limit).to eq(2)
    expect(order.coupon.expired?).to be_falsy

    expect(order.total).to eq(370)
    expect(order.total_with_discount).to eq(314.5)

    expect(order.coupon.usage_limit).to eq(1)
  end

  it 'has 2 products and a coupon based on OrderProduct model for order 456' do
    order = Order.find(456)

    expect(order.products).to have(2).products
    expect(order.products.map(&:value))
      .to contain_exactly(225, 250)

    expect(order.coupon_id).to eq(345)
    expect(order.coupon).to_not be_nil
    expect(order.coupon.value).to eq(50)
    expect(order.coupon.discount_type).to eq(:absolute)
    expect(order.coupon.usage_limit).to eq(1)

    expect(order.coupon.expired?).to be_truthy

    expect(order.total).to eq(475)
    expect(order.total_with_discount).to eq(427.5)

    expect(order.coupon.usage_limit).to eq(1)
  end

  it 'has 6 products and a coupon based on OrderProduct model for order 567' do
    order = Order.find(567)

    expect(order.products).to have(6).products
    expect(order.products.map(&:value))
      .to contain_exactly(150, 225, 120, 75, 100, 80)

    expect(order.coupon_id).to eq(456)
    expect(order.coupon).to_not be_nil
    expect(order.coupon.value).to eq(25)
    expect(order.coupon.discount_type).to eq(:percent)
    expect(order.coupon.usage_limit).to eq(2)

    expect(order.coupon.expired?).to be_falsy

    expect(order.total).to eq(750)
    expect(order.total_with_discount).to eq(525)

    expect(order.coupon.usage_limit).to eq(2)
  end

  it 'has 2 products and a coupon based on OrderProduct model for order 678' do
    order = Order.find(678)

    expect(order.products).to have(2).products
    expect(order.products.map(&:value))
      .to contain_exactly(2_400, 75)

    expect(order.coupon_id).to eq(567)
    expect(order.coupon).to_not be_nil
    expect(order.coupon.value).to eq(100)
    expect(order.coupon.discount_type).to eq(:absolute)
    expect(order.coupon.usage_limit).to eq(1)

    expect(order.coupon.expired?).to be_falsy

    expect(order.total).to eq(2475)
    expect(order.total_with_discount).to eq(2227.5)

    expect(order.coupon.usage_limit).to eq(1)
  end

  it 'has 5 products and a coupon based on OrderProduct model for order 789' do
    order = Order.find(789)

    expect(order.products).to have(5).products
    expect(order.products.map(&:value))
      .to contain_exactly(15_000, 150, 175, 2_400, 75)

    expect(order.coupon_id).to eq(789)
    expect(order.coupon).to_not be_nil
    expect(order.coupon.value).to eq(20)
    expect(order.coupon.discount_type).to eq(:percent)
    expect(order.coupon.usage_limit).to eq(1)

    expect(order.coupon.expired?).to be_falsy

    expect(order.total).to eq(17800)
    expect(order.total_with_discount).to eq(13350)

    expect(order.coupon.usage_limit).to eq(1)
  end
end

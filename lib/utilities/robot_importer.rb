module RobotImporter

  def self.import_from(options)
    api_data = get_json(options[:api_url])
    manufacturers = api_data['manufacturers']
    manufacturers.each do |manufacturer|
      update_manufacturer(manufacturer['name'])
      manufacturer['models'].each do |product|
        update_product(product, manufacturer['name'])
      end
    end
  end

  private
  def self.get_json(api_url)
    JSON.load(open(api_url))
  end

  def self.update_manufacturer(manufacturer)
    Manufacturer.find_or_create_by(name: manufacturer)
  end

  def self.update_product(model, manufacturer)
    producer = Manufacturer.find_by(name: manufacturer)
    Product.find_or_create_by(model_number: model['modelNo']) do |product|
      product.height = model['height']
      product.weight = model['weight']
      product.price = parse_price(model['price'])
      product.manufacturer = producer
    end
  end

  def self.parse_price(price)
    price.delete('$.')
  end
end

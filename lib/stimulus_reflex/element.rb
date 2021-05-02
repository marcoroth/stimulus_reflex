# frozen_string_literal: true

class StimulusReflex::Element < OpenStruct
  attr_reader :attrs, :data_attrs

  def initialize(data = {})
    @attrs = HashWithIndifferentAccess.new(data["attrs"] || {})
    datasets = data["dataset"] || {}
    regualar_dataset = datasets["dataset"] || {}
    @data_attrs = build_data_attrs(regualar_dataset, datasets["datasetArray"] || {})
    all_attributes = @attrs.merge(@data_attrs)
    super all_attributes.merge(all_attributes.transform_keys(&:underscore))
    @data_attrs.transform_keys! { |key| key.delete_prefix "data-" }
  end

  def signed
    @signed ||= ->(accessor) { GlobalID::Locator.locate_signed(dataset[accessor]) }
  end

  def unsigned
    @unsigned ||= ->(accessor) { GlobalID::Locator.locate(dataset[accessor]) }
  end

  def attributes
    @attributes ||= OpenStruct.new(attrs.merge(attrs.transform_keys(&:underscore)))
  end

  alias_method :data_attributes, :dataset

  def dataset
    @dataset ||= OpenStruct.new(data_attrs.merge(data_attrs.transform_keys(&:underscore)))
  end

  private

  def build_data_attrs(dataset, dataset_array)
    dataset_array.transform_keys! { |key| "data-#{key.delete_prefix("data-").pluralize}" }

    dataset.each { |key, value| dataset_array[key]&.prepend(value) }

    data_attrs = dataset.merge(dataset_array)

    HashWithIndifferentAccess.new(data_attrs || {})
  end
end

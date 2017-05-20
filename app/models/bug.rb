class Bug < ApplicationRecord
  has_one :state

  validates_presence_of :app_token, :status, :priority, :comment

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name    'instaapibugs'
  document_type 'bug'

  es_index_settings = {
    'analysis': {
      'filter': {
        'trigrams_filter': {
          'type':'ngram',
          'min_gram': 3,
          'max_gram': 3
        }
      },
      'analyzer': {
        'trigrams': {
          'type': 'custom',
          'tokenizer': 'standard',
          'filter': [
            'lowercase',
            'trigrams_filter'
          ]
        }
      }
    }
  }

  settings es_index_settings do
    mapping do
      indexes :comment, type: 'string', analyzer: 'trigrams'
    end
  end
end

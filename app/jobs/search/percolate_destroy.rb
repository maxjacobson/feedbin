module Search
  class PercolateDestroy
    include Sidekiq::Worker
    sidekiq_options queue: :network_search

    def perform(action_id)
      options = {
        index: Entry.index_name,
        type: ".percolator",
        id: action_id
      }
      $search.each do |_, client|
        client.delete(options)
      end
      Search::Client.delete(Action.table_name, id: action_id)
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
    end
  end
end
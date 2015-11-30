class Question

  def self.make_random
    cards = Card.order("RANDOM()").first(4)
    answer_id = rand(4)
    options = cards.map {|option| option.back}
    question = {Constants::JSON_QST_QUESTION => cards[answer_id].front, Constants::JSON_QST_OPTIONS => options, Constants::JSON_QST_ANSWER_ID => answer_id}
  end

end

class PubsController < ApplicationController
  skip_before_filter :authenticate_user!
  def tos
  end
  def about
    @header = "About us"
    @body = "Lorem ipsum. Dolor sit amet"
    @footer = ["Iure debitis perferendis sed quo repellat eos exercitationem eaque",
               "Sunt et perferendis quisquam commodi aliquid veniam exercitationem corrupti",
               "Delectus consequatur adipisci maiores corrupti occaecati dolorum",
               "Veritatis aut ut fuga sit cumque",
               "In id sunt cupiditate doloremque",
               "Et provident distinctio et vel sequi"]
  end
  def contact
  end
end

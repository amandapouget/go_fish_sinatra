# require 'spec_helper'
#
# describe Task do
#   # how to write a test for validate presence of description?
#
#   it('tells which list it belongs to') do
#     list = List.create({name: "my list"})
#     task = Task.create({description: "task", list_id: list.id})
#     expect(task.list).to eq(list)
#   end
#
#   it('validates presence of description') do
#     task = Task.new({description: ""})
#     expect(task.save).to eq(false)
#   end
#
#   it('validates the length of the description is at most 50 characters') do
#     task = Task.new({description: "a".*(51)})
#     expect(task.save).to eq(false)
#   end
#
#   it('converts the name to lowercase') do
#     task = Task.create({description: "FINAGLE THE BUFFALO"})
#     expect(task.description).to eq("finagle the buffalo")
#   end
#
#   describe(".not_done") do
#     it('returns the not done tasks') do
#       not_done_task1 = Task.create(description: "gotta do it", done: false)
#       not_done_task2 = Task.create(description: "gotta do it too", done: false)
#       not_done_tasks = [not_done_task1, not_done_task2]
#       done_task = Task.create(description: "done task", done: true)
#       expect(Task.not_done).to eq(not_done_tasks)
#     end
#   end
# end

require 'spec_helper'

describe User do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:match) { build(:match) }
  let(:match2) { build(:match) }

  after do
    User.delete_all
  end

  it 'has a name' do
    expect(user.name).to be > ""
  end

  it 'stores the last known client socket connection' do
    expect(user.client).to be nil
  end

  it 'returns the right user when given just an id' do
    expect(User.find(user.id)).to eq user
  end

  it 'knows what matches it has played but does not allow duplicates' do
    2.times { user.add_match(match) }
    user.add_match(match2)
    expect(user.matches).to match_array [match.object_id, match2.object_id]
  end

  describe NullUser do
    let(:nulluser) { build(:null_user) }
    let(:nulluser2) { build(:null_user) }

    it 'it has nil or empty array values for all attributes of regular User' do
      expect(nulluser.matches).to eq []
      expect(nulluser.name).to be nil
      expect(nulluser.client).to be nil
    end

    it 'does not raise exceptions when regular User methods are called on it' do
      expect { nulluser.save }.to_not raise_exception
      expect { nulluser.add_match(match) }.to_not raise_exception
    end

    it 'calls equal any two nullusers' do
      expect(nulluser == nulluser2).to be true
      expect(nulluser.eql?(nulluser2)).to be true
      expect(nulluser.hash == nulluser2.hash).to be true
    end

    it 'returns false when testing equality with a regular user' do
      expect(nulluser == user).to be false
      expect(nulluser.eql?(user)).to be false
      expect(nulluser.hash == user.hash).to be false
    end
  end
end

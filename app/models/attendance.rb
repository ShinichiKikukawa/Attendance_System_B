class Attendance < ApplicationRecord
  belongs_to :user
  #勤怠時間が存在しないとダメにする。
  validates :worked_on, presence: true
  #備考欄はマックス５０文字にして、５１文字以上はダメにする。
  validates :note, length: { maximum: 50 }
  # 出勤時間がない場合、退勤時間は無効で、出勤時間を求めるエラーメッセージを出させる。→退勤時間だけだとダメにする。
  validate :finished_at_is_invalid_without_a_started_at
  # 退勤時間がない場合、出勤時間は無効で、退勤時間を求めるエラーメッセージを出させる。→出勤時間だけだとダメにする。
  validate :started_at_is_invalid_without_a_finished_at, on: :update_one_month
  # 出勤・退勤時間どちらも存在する場合、出勤時間より早い退勤時間は無効。→辻綱があわないとダメにする。
  validate :started_at_than_finished_at_fast_if_invalid

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_is_invalid_without_a_finished_at
    errors.add(:finished_at, "が必要です") if finished_at.blank? && started_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
   if started_at.present? && finished_at.present?
     errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
   end
  end
end

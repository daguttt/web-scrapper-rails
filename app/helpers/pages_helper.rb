module PagesHelper
  include Pagy::Frontend

  STATUS_BADGE_CONTAINER_CLASSES = {
    'processing' => 'bg-yellow-100 text-yellow-800 dark:bg-yellow-800/30 dark:text-yellow-500',
    'success' => 'bg-green-100 text-green-800 dark:bg-green-800/30 dark:text-green-500',
    'failed' => 'bg-red-100 text-red-800 dark:bg-red-800/30 dark:text-red-500'
  }.freeze

  STATUS_BADGE_DOT_CLASSES = {
    'processing' => 'bg-yellow-800 dark:bg-yellow-500 animate-ping',
    'success' => 'bg-green-800 dark:bg-green-500',
    'failed' => 'bg-red-800 dark:bg-red-500'
  }.freeze

  def status_container_classes(status)
    STATUS_BADGE_CONTAINER_CLASSES[status]
  end

  def status_dot_classes(status)
    STATUS_BADGE_DOT_CLASSES[status]
  end
end

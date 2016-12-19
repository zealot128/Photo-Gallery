
def run(next_token)
  next_token = nil
  loop do
    print 'x'
    response = RekognitionClient.collection(max_results: 1000, next_token: next_token)
    response.faces.each do |face|
      print '.'
      ImageFace.where(aws_id: face.face_id).update_all confidence: face.confidence
    end
    if response.next_token
      next_token = response.next_token
    else
      break
    end
  end
end

run(nil)

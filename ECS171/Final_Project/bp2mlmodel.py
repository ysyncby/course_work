import tfcoreml as tf_converter
tf_converter.convert(tf_model_path = '/home/ysyncby/courses/ECS171_Machine_Learning/project/model/1.0/output_graph.pb',
                     mlmodel_path = 'mobilenetv2.mlmodel',
                     output_feature_names = ['final_result:0'],
                     image_input_names = ['Placeholder:0'],
		     class_labels = '/home/ysyncby/courses/ECS171_Machine_Learning/project/model/1.0/output_labels.txt',
                     image_scale = 2.0/255.0)

password = input("Enter password: ")  # usage simple, ok
# eval("print('danger')")  # dangereux
import ast
ast.literal_eval("print('danger')")  # plus sûr que eval

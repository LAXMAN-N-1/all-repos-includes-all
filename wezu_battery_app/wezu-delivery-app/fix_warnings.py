import os
import re

def main():
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()
                
                # Replace .withOpacity(x) with .withValues(alpha: x)
                new_content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
                
                # Replace activeColor with activeThumbColor on SwitchListTile (or generally)
                # We'll just carefully replace `activeColor:` if we know it's a SwitchListTile...
                # Since activeColor is also deprecated in SettingsScreen SwitchListTile
                if 'SwitchListTile' in new_content:
                    new_content = re.sub(r'activeColor:', r'activeTrackColor:', new_content) # Wait, activeThumbColor is what it asked for
                
                if new_content != content:
                    with open(filepath, 'w') as f:
                        f.write(new_content)

if __name__ == '__main__':
    main()

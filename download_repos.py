import os
import requests
import json
from urllib.parse import urljoin

# GitHub repositories to download from
repos = [
    {
        'url': 'https://github.com/alebinh60/asmobile',
        'branch': 'main',
        'name': 'alebinh60-asmobile'
    },
    {
        'url': 'https://github.com/yuvic123/SKIDO-V3',
        'branch': 'main',
        'name': 'yuvic123-SKIDO-V3'
    },
    {
        'url': 'https://github.com/Pixeluted/adoniscries',
        'branch': 'main',
        'name': 'Pixeluted-adoniscries'
    },
    {
        'url': 'https://github.com/Kazamatcha/asmobile',
        'branch': 'main',
        'name': 'Kazamatcha-asmobile'
    },
    {
        'url': 'https://github.com/CongoOhioDog/SoundS',
        'branch': 'main',
        'name': 'CongoOhioDog-SoundS'
    }
]

def get_repo_contents(owner, repo, path='', branch='main'):
    """Get all files from a GitHub repo using the API"""
    url = f'https://api.github.com/repos/{owner}/{repo}/contents/{path}?ref={branch}'
    
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"  Error: Status {response.status_code} for {url}")
            return []
    except Exception as e:
        print(f"  Error fetching {url}: {e}")
        return []

def download_file(download_url, save_path):
    """Download a single file"""
    try:
        response = requests.get(download_url, timeout=10)
        if response.status_code == 200:
            os.makedirs(os.path.dirname(save_path), exist_ok=True)
            with open(save_path, 'wb') as f:
                f.write(response.content)
            return True
    except Exception as e:
        print(f"    Error downloading {download_url}: {e}")
    return False

def download_repo_recursive(owner, repo, branch, save_dir, path='', depth=0):
    """Recursively download all files from a GitHub repo"""
    if depth > 5:  # Limit recursion depth
        return
    
    contents = get_repo_contents(owner, repo, path, branch)
    
    for item in contents:
        if item['type'] == 'file':
            relative_path = item['path']
            save_path = os.path.join(save_dir, relative_path)
            print(f"  Downloading: {relative_path}")
            download_file(item['download_url'], save_path)
        elif item['type'] == 'dir':
            download_repo_recursive(owner, repo, branch, save_dir, item['path'], depth + 1)

def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    output_dir = 'repo_downloads'
    os.makedirs(output_dir, exist_ok=True)
    
    print("🚀 Starting GitHub repository downloads...\n")
    
    for repo_info in repos:
        url_parts = repo_info['url'].split('/')
        owner = url_parts[-2]
        repo = url_parts[-1]
        branch = repo_info['branch']
        save_dir = os.path.join(output_dir, repo_info['name'])
        
        print(f"📦 Downloading: {owner}/{repo} ({branch})")
        download_repo_recursive(owner, repo, branch, save_dir)
        print(f"   ✓ Complete\n")
    
    print("✅ All downloads complete!")
    print(f"📁 Files saved to: {os.path.abspath(output_dir)}")

if __name__ == '__main__':
    main()

import requests

def count_words(subreddit, word_list, after=None, counts=None):
    if counts is None:
        counts = {}

    url = f"https://www.reddit.com/r/{subreddit}/hot.json"
    headers = {'User-agent': 'WordCounterBot'}
    params = {'limit': '100', 'after': after}

    response = requests.get(url, headers=headers, params=params)
    if response.status_code != 200:
        return

    data = response.json()
    after = data['data']['after']
    posts = data['data']['children']

    for post in posts:
        title = post['data']['title'].lower()
        for word in word_list:
            if word.lower() in title:
                if word in counts:
                    counts[word] += title.count(word.lower())
                else:
                    counts[word] = title.count(word.lower())

    if after is not None:
        count_words(subreddit, word_list, after, counts)
    else:
        sorted_counts = sorted(counts.items(), key=lambda x: (-x[1], x[0]))
        for word, count in sorted_counts:
            print(word.lower(), count)

# Example usage:
count_words("python", ["python", "java", "javascript"])


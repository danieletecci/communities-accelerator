const formatContent = (content, type, device) => {
    let formatedContent;
    let fileUrlDevice;
    if(device === 'DESKTOP'){
        fileUrlDevice = 'FileURLDesktop';
    } else if (device === 'PHONE'){
        fileUrlDevice = 'FileURLMobile';
    } else {
        fileUrlDevice = 'FileURLTablet';
    }
    let temp = content.mediaElements.length > 0 ? content.mediaElements[0] : {};
    if (content.content !== null && !formatedContent) {
        if (type === 'EventList') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                startDate: content.content.EventStartDate,
                endDate: content.content.EventEndDate,
                title: content.content.Title,
                bodyText: content.content.Extract,
                imgSrc: temp[fileUrlDevice],
                footer: {
                    description: {
                        descSecondary: content.content.Location
                    },
                },
            };
        }
        else if(type === 'ArticleList') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                date: content.content.PublishStartDate,
                title: content.content.Title,
                bodyText: content.content.Extract,
                imgSrc: temp[fileUrlDevice]
            };
        } else {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                headerText: null,
                title: content.content.Title,
                bodyText: content.content.Extract,
                imgSrc: temp[fileUrlDevice]
            };
        }
    }
    return formatedContent;
}

const formatContentCompressed = (content, type, device) => {
    let formatedContent;
    let fileUrlDevice;
    if(device === 'DESKTOP'){
        fileUrlDevice = 'FileURLDesktop';
    } else if (device === 'PHONE'){
        fileUrlDevice = 'FileURLMobile';
    } else {
        fileUrlDevice = 'FileURLTablet';
    }
    let temp = content.mediaElements.length > 0 ? content.mediaElements[0] : {};
    if (content.content !== null && !formatedContent) {
        if (type === 'EventList' || type === 'EventsRelated') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                startDate: content.content.EventStartDate,
                endDate: content.content.EventEndDate,
                title: content.content.Title,
                imgSrc: temp[fileUrlDevice],
                description: content.content.Extract,
                location: content.content.Location
            };
        }
        else if(type === 'ArticleList' || type === 'ArticlesRelated') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                date: content.content.PublishStartDate,
                title: content.content.Title,
                imgSrc: temp[fileUrlDevice],
                description: content.content.Extract
            };
        } else {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId,
                type: type,
                headerText: null,
                title: content.content.Title,
                imgSrc: temp[fileUrlDevice],
                description: null
            };
        }
    }
    return formatedContent;
}

export {formatContent, formatContentCompressed};
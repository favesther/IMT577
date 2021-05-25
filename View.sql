SELECT   dbo.Channel.Channel
FROM     dbo.Channel INNER JOIN
             dbo.ChannelCategory ON dbo.Channel.ChannelCategoryID = dbo.ChannelCategory.ChannelCategoryID